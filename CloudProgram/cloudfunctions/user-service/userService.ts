/// <reference types="node" />

import * as dbServer from '@agconnect/database-server';
import * as authServer from '@agconnect/auth-server';

// 数据模型接口
interface User {
    id: string;
    username: string;
    email: string;
    phoneNumber: string;
    avatarUrl: string;
    registerTime: string;
    lastLoginTime: string;
    favoriteArtifacts: string[];
    favoriteMuseums: string[];
    visitHistory: VisitRecord[];
}

interface VisitRecord {
    museumId: string;
    visitTime: string;
    duration: number;
}

interface UserCollection {
    userId: string;
    artifactId: string;
    collectionTime: string;
}

interface CloudDBError {
    code: number;
    message: string;
}

export class UserService {
    private client: any;
    private authClient: any;
    private readonly zoneName = 'Museum';
    private isInitialized = false;

    constructor() {
        // 创建CloudDB客户端（延迟初始化）
    }

    /**
     * 初始化数据库连接
     */
    private async initClient() {
        if (this.isInitialized) return;

        try {
            console.log('初始化CloudDB客户端...');
            // 使用华为云API初始化数据库和认证服务
            const db = dbServer.agconnect.cloudDB();
            this.client = db.openZone(this.zoneName);
            this.authClient = authServer.agconnect.auth();
            this.isInitialized = true;
            console.log('CloudDB和Auth客户端初始化成功');
        } catch (err) {
            console.error('初始化CloudDB客户端失败:', err);
            throw {
                code: 500,
                message: '云数据库连接失败'
            };
        }
    }

    /**
     * 用户登录
     */
    async login(params: { username: string; password: string }) {
        await this.initClient();

        try {
            const { username, password } = params;

            // 使用华为云认证服务进行登录
            const result = await this.authClient.signIn({
                account: username,
                password: password
            });

            // 获取用户信息
            const userId = result.getUser().getUid();
            const userData = await this.getUserById(userId);

            // 更新最后登录时间
            await this.updateLastLoginTime(userId);

            return {
                token: result.getToken(),
                user: userData
            };
        } catch (err) {
            console.error('用户登录失败:', err);
            throw {
                code: (err as CloudDBError).code || 401,
                message: (err as CloudDBError).message || '用户名或密码错误'
            };
        }
    }

    /**
     * 用户注册
     */
    async register(params: { username: string; password: string; email: string; phoneNumber: string }) {
        await this.initClient();

        try {
            const { username, password, email, phoneNumber } = params;

            // 检查用户名是否已存在
            const isExist = await this.checkUserExists(username);
            if (isExist) {
                throw {
                    code: 400,
                    message: '用户名已存在'
                };
            }

            // 使用华为云认证服务创建用户
            const result = await this.authClient.createUser({
                displayName: username,
                password: password,
                email: email,
                phoneNumber: phoneNumber
            });

            const userId = result.getUid();

            // 创建用户记录
            const userClass = require('./User.js').default;
            const userObj = new userClass();
            userObj.setId(userId);
            userObj.setUsername(username);
            userObj.setEmail(email);
            userObj.setPhoneNumber(phoneNumber);
            userObj.setAvatarUrl('');
            userObj.setRegisterTime(new Date().toISOString());
            userObj.setLastLoginTime(new Date().toISOString());
            userObj.setFavoriteArtifacts([]);
            userObj.setFavoriteMuseums([]);
            userObj.setVisitHistory([]);

            await this.client.executeUpsert(userObj);

            return {
                userId,
                username
            };
        } catch (err) {
            console.error('用户注册失败:', err);
            throw {
                code: (err as CloudDBError).code || 500,
                message: (err as CloudDBError).message || '用户注册失败'
            };
        }
    }

    /**
     * 获取用户信息
     */
    async getUserById(userId: string) {
        await this.initClient();

        try {
            const userClass = require('./User.js').default;
            const query = this.client.query(userClass).equalTo('id', userId);
            const snapshot = await this.client.executeQuery(query);

            if (snapshot.hasNext()) {
                const item = snapshot.next();
                const user: User = {
                    id: item.getId(),
                    username: item.getUsername(),
                    email: item.getEmail(),
                    phoneNumber: item.getPhoneNumber(),
                    avatarUrl: item.getAvatarUrl(),
                    registerTime: item.getRegisterTime(),
                    lastLoginTime: item.getLastLoginTime(),
                    favoriteArtifacts: item.getFavoriteArtifacts(),
                    favoriteMuseums: item.getFavoriteMuseums(),
                    visitHistory: item.getVisitHistory()
                };

                snapshot.release();
                return user;
            } else {
                snapshot.release();
                throw {
                    code: 404,
                    message: '用户不存在'
                };
            }
        } catch (err) {
            console.error('获取用户信息失败:', err);
            throw {
                code: (err as CloudDBError).code || 500,
                message: (err as CloudDBError).message || '获取用户信息失败'
            };
        }
    }

    /**
     * 更新用户头像
     */
    async updateUserAvatar(userId: string, avatarUrl: string) {
        await this.initClient();

        try {
            const userClass = require('./User.js').default;
            const query = this.client.query(userClass).equalTo('id', userId);
            const snapshot = await this.client.executeQuery(query);

            if (snapshot.hasNext()) {
                const item = snapshot.next();
                item.setAvatarUrl(avatarUrl);

                await this.client.executeUpsert(item);
                snapshot.release();

                return { success: true };
            } else {
                snapshot.release();
                throw {
                    code: 404,
                    message: '用户不存在'
                };
            }
        } catch (err) {
            console.error('更新用户头像失败:', err);
            throw {
                code: (err as CloudDBError).code || 500,
                message: (err as CloudDBError).message || '更新用户头像失败'
            };
        }
    }

    /**
     * 收藏/取消收藏文物
     */
    async toggleFavoriteArtifact(userId: string, artifactId: string) {
        await this.initClient();

        try {
            const userClass = require('./User.js').default;
            const query = this.client.query(userClass).equalTo('id', userId);
            const snapshot = await this.client.executeQuery(query);

            if (snapshot.hasNext()) {
                const item = snapshot.next();
                const favorites = item.getFavoriteArtifacts() || [];

                const index = favorites.indexOf(artifactId);
                let action = '';

                if (index === -1) {
                    // 添加收藏
                    favorites.push(artifactId);
                    action = 'add';
                } else {
                    // 取消收藏
                    favorites.splice(index, 1);
                    action = 'remove';
                }

                item.setFavoriteArtifacts(favorites);
                await this.client.executeUpsert(item);

                // 处理收藏记录
                if (action === 'add') {
                    await this.addUserCollection(userId, artifactId);
                } else {
                    await this.removeUserCollection(userId, artifactId);
                }

                snapshot.release();
                return {
                    success: true,
                    action: action
                };
            } else {
                snapshot.release();
                throw {
                    code: 404,
                    message: '用户不存在'
                };
            }
        } catch (err) {
            console.error('操作收藏文物失败:', err);
            throw {
                code: (err as CloudDBError).code || 500,
                message: (err as CloudDBError).message || '操作收藏文物失败'
            };
        }
    }

    /**
     * 添加收藏记录
     */
    private async addUserCollection(userId: string, artifactId: string) {
        try {
            const collectionClass = require('./UserCollection.js').default;
            const collection = new collectionClass();
            collection.setUserId(userId);
            collection.setArtifactId(artifactId);
            collection.setCollectionTime(new Date().toISOString());

            await this.client.executeUpsert(collection);
        } catch (err) {
            console.error('添加收藏记录失败:', err);
            // 不中断主流程，仅记录错误
        }
    }

    /**
     * 移除收藏记录
     */
    private async removeUserCollection(userId: string, artifactId: string) {
        try {
            const collectionClass = require('./UserCollection.js').default;
            const query = this.client.query(collectionClass)
                .equalTo('userId', userId)
                .equalTo('artifactId', artifactId);

            const snapshot = await this.client.executeQuery(query);

            if (snapshot.hasNext()) {
                const item = snapshot.next();
                await this.client.executeDelete(item);
            }

            snapshot.release();
        } catch (err) {
            console.error('移除收藏记录失败:', err);
            // 不中断主流程，仅记录错误
        }
    }

    /**
     * 检查用户是否存在
     */
    private async checkUserExists(username: string): Promise<boolean> {
        try {
            const userClass = require('./User.js').default;
            const query = this.client.query(userClass).equalTo('username', username);
            const count = await this.client.count(query);
            return count > 0;
        } catch (err) {
            console.error('检查用户是否存在失败:', err);
            throw err;
        }
    }

    /**
     * 更新最后登录时间
     */
    private async updateLastLoginTime(userId: string) {
        try {
            const userClass = require('./User.js').default;
            const query = this.client.query(userClass).equalTo('id', userId);
            const snapshot = await this.client.executeQuery(query);

            if (snapshot.hasNext()) {
                const item = snapshot.next();
                item.setLastLoginTime(new Date().toISOString());
                await this.client.executeUpsert(item);
            }

            snapshot.release();
        } catch (err) {
            console.error('更新最后登录时间失败:', err);
            // 不中断主流程，仅记录错误
        }
    }
} 