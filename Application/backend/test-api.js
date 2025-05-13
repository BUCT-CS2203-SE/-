/*
 * @Author: LokiYu 2915399378@qq.com
 * @Date: 2025-05-13 10:29:39
 * @LastEditors: LokiYu 2915399378@qq.com
 * @LastEditTime: 2025-05-13 10:29:44
 * @FilePath: \HandHeld_Museum\Application\backend\test-api.js
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
/**
 * API接口测试脚本
 */
const http = require('http');

// 配置要测试的API
const testApis = [
    { path: '/api/artifacts?page=1&pageSize=5', method: 'GET', description: '获取文物列表' },
    { path: '/api/artifacts/1', method: 'GET', description: '获取ID为1的文物详情' }
];

// 测试函数
async function testApi(api) {
    return new Promise((resolve, reject) => {
        console.log(`\n测试API: ${api.description}`);
        console.log(`${api.method} http://localhost:3000${api.path}`);

        const options = {
            hostname: 'localhost',
            port: 3000,
            path: api.path,
            method: api.method
        };

        const req = http.request(options, (res) => {
            console.log(`状态码: ${res.statusCode}`);

            let data = '';
            res.on('data', (chunk) => {
                data += chunk;
            });

            res.on('end', () => {
                try {
                    const jsonData = JSON.parse(data);
                    console.log('响应摘要:');
                    if (jsonData.data && Array.isArray(jsonData.data)) {
                        console.log(`- 返回记录数: ${jsonData.data.length}`);
                        if (jsonData.data.length > 0) {
                            console.log(`- 第一条记录: ${JSON.stringify(jsonData.data[0]).substring(0, 150)}...`);
                        }
                    } else if (jsonData.data) {
                        console.log(`- 数据: ${JSON.stringify(jsonData.data).substring(0, 150)}...`);
                    } else {
                        console.log(`- 响应: ${JSON.stringify(jsonData).substring(0, 150)}...`);
                    }
                    resolve(jsonData);
                } catch (error) {
                    console.error('解析响应失败:', error);
                    console.log('原始响应:', data.substring(0, 150) + '...');
                    reject(error);
                }
            });
        });

        req.on('error', (error) => {
            console.error(`请求失败: ${error.message}`);
            reject(error);
        });

        req.end();
    });
}

// 运行测试
async function runTests() {
    console.log('开始API测试...');

    for (const api of testApis) {
        try {
            await testApi(api);
        } catch (error) {
            console.error(`API测试失败: ${api.description}`, error.message);
        }
    }

    console.log('\nAPI测试完成');
}

// 启动测试
runTests(); 