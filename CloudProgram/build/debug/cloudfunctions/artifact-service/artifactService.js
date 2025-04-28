"use strict";
/// <reference types="node" />
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g;
    return g = { next: verb(0), "throw": verb(1), "return": verb(2) }, typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (g && (g = 0, op[0] && (_ = 0)), _) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
exports.__esModule = true;
exports.ArtifactService = void 0;
var dbServer = __importStar(require("@agconnect/database-server"));
var ArtifactService = /** @class */ (function () {
    function ArtifactService() {
        this.zoneName = 'Museum';
        this.isInitialized = false;
        // 创建CloudDB客户端（延迟初始化）
    }
    /**
     * 初始化数据库连接
     */
    ArtifactService.prototype.initClient = function () {
        return __awaiter(this, void 0, void 0, function () {
            var db;
            return __generator(this, function (_a) {
                if (this.isInitialized)
                    return [2 /*return*/];
                try {
                    console.log('初始化CloudDB客户端...');
                    db = dbServer.initializeApp();
                    this.client = db.cloudDB().openZone(this.zoneName);
                    this.isInitialized = true;
                    console.log('CloudDB客户端初始化成功');
                }
                catch (err) {
                    console.error('初始化CloudDB客户端失败:', err);
                    throw {
                        code: 500,
                        message: '云数据库连接失败'
                    };
                }
                return [2 /*return*/];
            });
        });
    };
    /**
     * 获取文物列表，支持分页和分类筛选
     */
    ArtifactService.prototype.getArtifactList = function (params) {
        return __awaiter(this, void 0, void 0, function () {
            var categoryId, _a, page, _b, pageSize, Class, query, countQuery, totalCount, startIndex, snapshot, artifacts, item, err_1;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0: return [4 /*yield*/, this.initClient()];
                    case 1:
                        _c.sent();
                        _c.label = 2;
                    case 2:
                        _c.trys.push([2, 5, , 6]);
                        categoryId = params.categoryId, _a = params.page, page = _a === void 0 ? 1 : _a, _b = params.pageSize, pageSize = _b === void 0 ? 10 : _b;
                        Class = require('./Artifact.js')["default"];
                        query = this.client.query(Class);
                        if (categoryId !== undefined) {
                            query.equalTo('categoryId', categoryId);
                        }
                        countQuery = this.client.query(Class);
                        if (categoryId !== undefined) {
                            countQuery.equalTo('categoryId', categoryId);
                        }
                        return [4 /*yield*/, this.client.count(countQuery)];
                    case 3:
                        totalCount = _c.sent();
                        startIndex = (page - 1) * pageSize;
                        query.limit(pageSize).skip(startIndex); // 使用skip代替offset
                        return [4 /*yield*/, this.client.executeQuery(query)];
                    case 4:
                        snapshot = _c.sent();
                        artifacts = [];
                        while (snapshot.hasNext()) {
                            item = snapshot.next();
                            artifacts.push({
                                id: item.getId(),
                                name: item.getName(),
                                era: item.getEra(),
                                museum: item.getMuseum(),
                                description: item.getDescription(),
                                imageUrl: item.getImageUrl(),
                                categoryId: item.getCategoryId(),
                                detailUrl: item.getDetailUrl(),
                                likes: item.getLikes(),
                                comments: item.getComments()
                            });
                        }
                        // 关闭查询结果
                        snapshot.release();
                        return [2 /*return*/, { artifacts: artifacts, totalCount: totalCount }];
                    case 5:
                        err_1 = _c.sent();
                        console.error('获取文物列表失败:', err_1);
                        throw {
                            code: err_1.code || 500,
                            message: err_1.message || '获取文物列表失败'
                        };
                    case 6: return [2 /*return*/];
                }
            });
        });
    };
    /**
     * 获取文物详情
     */
    ArtifactService.prototype.getArtifactDetail = function (artifactId) {
        return __awaiter(this, void 0, void 0, function () {
            var Class, query, snapshot, item, artifact, err_2;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this.initClient()];
                    case 1:
                        _a.sent();
                        _a.label = 2;
                    case 2:
                        _a.trys.push([2, 4, , 5]);
                        Class = require('./Artifact.js')["default"];
                        query = this.client.query(Class).equalTo('id', artifactId);
                        return [4 /*yield*/, this.client.executeQuery(query)];
                    case 3:
                        snapshot = _a.sent();
                        if (snapshot.hasNext()) {
                            item = snapshot.next();
                            artifact = {
                                id: item.getId(),
                                name: item.getName(),
                                era: item.getEra(),
                                museum: item.getMuseum(),
                                description: item.getDescription(),
                                imageUrl: item.getImageUrl(),
                                categoryId: item.getCategoryId(),
                                detailUrl: item.getDetailUrl(),
                                likes: item.getLikes(),
                                comments: item.getComments()
                            };
                            // 关闭查询结果
                            snapshot.release();
                            return [2 /*return*/, artifact];
                        }
                        else {
                            // 关闭查询结果
                            snapshot.release();
                            throw {
                                code: 404,
                                message: '文物不存在'
                            };
                        }
                        return [3 /*break*/, 5];
                    case 4:
                        err_2 = _a.sent();
                        console.error('获取文物详情失败:', err_2);
                        throw {
                            code: err_2.code || 500,
                            message: err_2.message || '获取文物详情失败'
                        };
                    case 5: return [2 /*return*/];
                }
            });
        });
    };
    /**
     * 关键词搜索文物
     */
    ArtifactService.prototype.searchArtifacts = function (keyword) {
        return __awaiter(this, void 0, void 0, function () {
            var Class, nameQuery, descQuery, museumQuery, eraQuery, combinedQuery, snapshot, artifacts, item, err_3;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this.initClient()];
                    case 1:
                        _a.sent();
                        _a.label = 2;
                    case 2:
                        _a.trys.push([2, 4, , 5]);
                        Class = require('./Artifact.js')["default"];
                        nameQuery = this.client.query(Class).contains('name', keyword);
                        descQuery = this.client.query(Class).contains('description', keyword);
                        museumQuery = this.client.query(Class).contains('museum', keyword);
                        eraQuery = this.client.query(Class).contains('era', keyword);
                        combinedQuery = this.client.queryBuilder()
                            .or(nameQuery, descQuery, museumQuery, eraQuery)
                            .build();
                        return [4 /*yield*/, this.client.executeQuery(combinedQuery)];
                    case 3:
                        snapshot = _a.sent();
                        artifacts = [];
                        while (snapshot.hasNext()) {
                            item = snapshot.next();
                            artifacts.push({
                                id: item.getId(),
                                name: item.getName(),
                                era: item.getEra(),
                                museum: item.getMuseum(),
                                description: item.getDescription(),
                                imageUrl: item.getImageUrl(),
                                categoryId: item.getCategoryId(),
                                detailUrl: item.getDetailUrl(),
                                likes: item.getLikes(),
                                comments: item.getComments()
                            });
                        }
                        // 关闭查询结果
                        snapshot.release();
                        return [2 /*return*/, artifacts];
                    case 4:
                        err_3 = _a.sent();
                        console.error('搜索文物失败:', err_3);
                        throw {
                            code: err_3.code || 500,
                            message: err_3.message || '搜索文物失败'
                        };
                    case 5: return [2 /*return*/];
                }
            });
        });
    };
    /**
     * 获取文物评论列表
     */
    ArtifactService.prototype.getArtifactComments = function (artifactId) {
        return __awaiter(this, void 0, void 0, function () {
            var CommentClass, query, snapshot, comments, item, err_4;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this.initClient()];
                    case 1:
                        _a.sent();
                        _a.label = 2;
                    case 2:
                        _a.trys.push([2, 4, , 5]);
                        CommentClass = require('./Comment.js')["default"];
                        query = this.client.query(CommentClass)
                            .equalTo('artifactId', artifactId)
                            .orderBy('createTimestamp', 'desc');
                        return [4 /*yield*/, this.client.executeQuery(query)];
                    case 3:
                        snapshot = _a.sent();
                        comments = [];
                        while (snapshot.hasNext()) {
                            item = snapshot.next();
                            comments.push({
                                id: item.getId(),
                                artifactId: item.getArtifactId(),
                                userId: item.getUserId(),
                                username: item.getUsername(),
                                avatarUrl: item.getAvatarUrl(),
                                content: item.getContent(),
                                createTime: item.getCreateTime(),
                                createTimestamp: item.getCreateTimestamp()
                            });
                        }
                        // 关闭查询结果
                        snapshot.release();
                        return [2 /*return*/, comments];
                    case 4:
                        err_4 = _a.sent();
                        console.error('获取评论列表失败:', err_4);
                        throw {
                            code: err_4.code || 500,
                            message: err_4.message || '获取评论列表失败'
                        };
                    case 5: return [2 /*return*/];
                }
            });
        });
    };
    return ArtifactService;
}());
exports.ArtifactService = ArtifactService;
//# sourceMappingURL=artifactService.js.map