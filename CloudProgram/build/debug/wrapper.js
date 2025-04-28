// Copyright (c) Huawei Technologies Co., Ltd. 2021-2021. All rights reserved.

const fs = require('fs');
const http = require('http');
const express = require('express');
const log4js = require("log4js");
const bodyParser = require('body-parser');
const path = require("path");
const CONTEXT_PREFIX = "x-context-";
const USER_ERROR = 180000;
const contentTypeJson = "application/json";

let invokeApp = express();

let router = express.Router();

let funcEnv = {};
const funcMap = new Map();

let args = process.argv.slice(2);
if (args.length !== 1 && args.length !== 2) {
    throw new Error(`param error`);
}

load().then(() => {
    getLogger().info('Cloud Functions loaded successfully.');
    process.on('uncaughtException', (err) => {
        getLogger().error('uncaughtException', err);
    });
}).catch((err) => {
    getLogger().error('Cloud Function loaded error:', err);
    process.exit(1);
});

async function load() {
    process.setMaxListeners(0)
    http.createServer(invokeApp).listen(args[0], 'localhost');
    getLogger().info(`HTTP server created successfully, with the listening port: ${args[0]}.`);
    if (args[1]) {
        let initEnvs = JSON.parse(fs.readFileSync(args[1], 'utf-8'));
        fs.unlinkSync(args[1]);
        loadFuncEnv(initEnvs.envs);
    }
    loadFunc('artifact-service', 'D:\\VSCODE\\HandHeld_Museum\\CloudProgram\\build\\debug\\cloudfunctions\\artifact-service\\artifactService.js', 'ArtifactService');
}

function loadFunc(functionName, entry, handler) {
    funcMap.set(functionName, {entry: entry, handler: handler})
    require(entry)
    getLogger().info('Function URI: http://localhost:' + args[0] + '/' + functionName + '/invoke.');
}

function loadFuncEnv(envs) {
    if (envs !== null && envs !== undefined) {
        for (let key in envs) {
            funcEnv[key] = envs[key];
            process.env[key] = envs[key];
        }
    }
}

router.post('/:func/invoke', invokeFunction);

invokeApp.use(bodyParser.json());
invokeApp.use("/", router);

function getLogger(category = 'function-runtime') {
    let logger = log4js.getLogger(category);
    logger.level = "info";
    return logger;
}

async function invokeFunction(req, res) {
    let context = new Context(req, res);
    setContext(context, handlerRequestHeader(req.headers));
    let funcName = req.params.func
    let functionHandler = retrieveFunctionHandler(funcName);
    if (!functionHandler) {
        return;
    }
    getLogger().debug(`invoke function ${funcName} start.`);
    let result;
    if (isCloudObject(funcName)) {
        getLogger().debug(`invoke cloud object start.`);
        getLogger().debug(req.body)
        let body = req.body.body;
        let method = body.method;
        if (!method) {
            getLogger().error('method can not be empty!');
            res.status(200).send('method can not be empty!');
            return;
        }
        let cloudObject = new functionHandler();
        let consoleSave = console;
        console = getLogger(funcName)
        try {
            if (!cloudObject[method]) {
                res.status(200).send({
                    statusCode: USER_ERROR,
                    message: `Call handler error, Can't find cloud object method: ${method}`
                });
                return;
            }
            result = await cloudObject[method](...body.params);
        } catch (e) {
            res.status(200).send({
                statusCode: USER_ERROR,
                message: `Call method exception: ${e.stack}`
            });
            return;
        } finally {
            console = consoleSave;
        }
        getLogger().debug(result);
        res.status(200).send(new Response(result));
    } else {
        try {
            result = functionHandler(req.body, context, context.callback, getLogger(funcName));
        } catch (error) {
            handlerTerminatedWithException(error);
            return;
        }
        if (result instanceof Promise) {
            result.then(() => {
                handlerTerminatedNotInvokeCallback();
            }).catch((error) => {
                handlerTerminatedWithException(error);
            });
        } else {
            handlerTerminatedNotInvokeCallback();
        }
    }

    function retrieveFunctionHandler(funcName) {
        let func = funcMap.get(funcName);
        if (func === undefined) {
            functionNotRunning();
            return null;
        }
        let entry = func.entry
        let handler = func.handler
        let functionModule = require(entry);
        if (functionModule === undefined) {
            throw new Error(`Can't find entry file ${entry}`);
        }
        let handlerFunc = functionModule[handler];
        if (handlerFunc === undefined) {
            throw new Error(`Can't find function name ${handler}`);
        }
        return handlerFunc;
    }

    function functionNotRunning() {
        var msg = `Cloud Function '${funcName}' is not running, please run it and try again.`;
        getLogger().error(msg)
        res.status(404).send({
            statusCode: 404,
            message: msg
        });
    }

    function handlerTerminatedNotInvokeCallback() {
        if (!context.hasInvokedCallback) {
            sendResponse(context, new FError(USER_ERROR, `Function ${funcName}'s handler terminated abnormally, ` +
                `Didn't invoke callback function.`));
        }
    }

    function handlerTerminatedWithException(error) {
        getLogger().error(`invoke function ${funcName} error.`, error);
        sendResponse(context, new FError(USER_ERROR, `invoke function ${funcName} error. ${error.stack}`));
    }
}

function isCloudObject(funcName) {
    let func = funcMap.get(funcName);
    var functionConfigPath = path.join(path.dirname(func.entry), "function-config.json");
    var functionConfigContent = fs.readFileSync(functionConfigPath, 'utf8');
    var functionConfig = JSON.parse(functionConfigContent);
    if (!functionConfig.hasOwnProperty('functionType')) {
        return false;
    }
    return functionConfig.functionType === 1;
}

function handlerRequestHeader(headers) {
    let eventHeaderMap = new Map();
    for (let [key, value] of Object.entries(headers)) {
        key = key.toLocaleLowerCase();
        if (key.indexOf(CONTEXT_PREFIX) === 0) {
            let keyWithoutPrefix = key.replace(CONTEXT_PREFIX, '');
            let valueMap = new Map();
            value.split(";").forEach((value) => {
                let v = value.split("=");
                if (v.length !== 2) {
                    throw new Error(`header ${v} malformed`)
                }
                valueMap[v[0]] = v[1]
            })
            eventHeaderMap[keyWithoutPrefix] = valueMap;
        }
    }
    return eventHeaderMap;
}

function setContext(context, eventHeaderMap) {
    for (let [key, value] of Object.entries(eventHeaderMap)) {
        key = key.toLocaleLowerCase();
        context[key] = value;
    }
}

let Context = function (req, res) {
    this.res = res;
    this.env = {...funcEnv};
    this.hasInvokedCallback = false;
    let self = this;
    this.callback = function () {
        responseFromOutput(self, ...arguments);
        self.hasInvokedCallback = true;
    };
};

function responseFromOutput() {
    let context = arguments[0];

    if (arguments[1] instanceof FError || arguments[1] instanceof Error) {
        sendResponse(context, arguments[1], arguments[2]);
    } else {
        sendResponse(context, undefined, arguments[1]);
    }
}

function sendResponse(context, err, body) {
    try {
        var msg = body ? body : err;
        var resStatus = msg.statusCode;
        var resBody = body ? body.body : null;
        var response = resBody ? resBody : msg;
        var resHeaders = body ? body.headers : null;
        context.res.status(resStatus ? resStatus : 200).set(resHeaders ? resHeaders : "").send(response);
    } catch (e) {
        // ignore
    }
}

Context.prototype.HTTPResponse = Response;
Context.prototype.Error = FError;

function Response(body = null, headers = null, contentType = "text/plain", statusCode = 200, isBase64Encoded = false) {
    this.body = body;
    this.headers = headers;
    this.contentType = contentType;
    this.statusCode = statusCode;
    this.isBase64Encoded = isBase64Encoded;

    if (!isString(this.body)) {
        this.body = JSON.stringify(this.body);
        this.contentType = contentTypeJson;
    }
}

function isString(obj) {
    return typeof obj === "string" || obj instanceof String;
}

function FError(code = 0, message = "") {
    this.code = code;
    this.message = message;
}