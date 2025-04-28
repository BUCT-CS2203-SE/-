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
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.ArtifactService = void 0;
const dbServer = __importStar(require("@agconnect/database-server"));
class ArtifactService {
    constructor() {
        this.zoneName = 'Museum';
        this.isInitialized = false;
        // 创建CloudDB客户端（延迟初始化）
    }
    /**
     * 初始化数据库连接
     */
    async initClient() {
        if (this.isInitialized)
            return;
        try {
            console.log('初始化CloudDB客户端...');
            // 使用正确的API初始化数据库
            const db = dbServer.initializeApp();
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
    }
    /**
     * 获取文物列表，支持分页和分类筛选
     */
    async getArtifactList(params) {
        await this.initClient();
        try {
            const { categoryId, page = 1, pageSize = 10 } = params;
            const Class = require('./Artifact.js').default;
            // 创建查询
            const query = this.client.query(Class);
            if (categoryId !== undefined) {
                query.equalTo('categoryId', categoryId);
            }
            // 计算总数
            const countQuery = this.client.query(Class);
            if (categoryId !== undefined) {
                countQuery.equalTo('categoryId', categoryId);
            }
            const totalCount = await this.client.count(countQuery);
            // 设置分页
            const startIndex = (page - 1) * pageSize;
            query.limit(pageSize).skip(startIndex); // 使用skip代替offset
            // 执行查询
            const snapshot = await this.client.executeQuery(query);
            let artifacts = [];
            while (snapshot.hasNext()) {
                const item = snapshot.next();
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
            return { artifacts, totalCount };
        }
        catch (err) {
            console.error('获取文物列表失败:', err);
            throw {
                code: err.code || 500,
                message: err.message || '获取文物列表失败'
            };
        }
    }
    /**
     * 获取文物详情
     */
    async getArtifactDetail(artifactId) {
        await this.initClient();
        try {
            const Class = require('./Artifact.js').default;
            // 创建查询
            const query = this.client.query(Class).equalTo('id', artifactId);
            const snapshot = await this.client.executeQuery(query);
            if (snapshot.hasNext()) {
                const item = snapshot.next();
                const artifact = {
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
                return artifact;
            }
            else {
                // 关闭查询结果
                snapshot.release();
                throw {
                    code: 404,
                    message: '文物不存在'
                };
            }
        }
        catch (err) {
            console.error('获取文物详情失败:', err);
            throw {
                code: err.code || 500,
                message: err.message || '获取文物详情失败'
            };
        }
    }
    /**
     * 关键词搜索文物
     */
    async searchArtifacts(keyword) {
        await this.initClient();
        try {
            const Class = require('./Artifact.js').default;
            // 搜索多个字段使用组合查询
            // 创建查询，搜索名称
            const nameQuery = this.client.query(Class).contains('name', keyword);
            const descQuery = this.client.query(Class).contains('description', keyword);
            const museumQuery = this.client.query(Class).contains('museum', keyword);
            const eraQuery = this.client.query(Class).contains('era', keyword);
            // 组合查询
            const combinedQuery = this.client.queryBuilder()
                .or(nameQuery, descQuery, museumQuery, eraQuery)
                .build();
            const snapshot = await this.client.executeQuery(combinedQuery);
            let artifacts = [];
            while (snapshot.hasNext()) {
                const item = snapshot.next();
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
            return artifacts;
        }
        catch (err) {
            console.error('搜索文物失败:', err);
            throw {
                code: err.code || 500,
                message: err.message || '搜索文物失败'
            };
        }
    }
    /**
     * 获取文物评论列表
     */
    async getArtifactComments(artifactId) {
        await this.initClient();
        try {
            const CommentClass = require('./Comment.js').default;
            // 创建查询
            const query = this.client.query(CommentClass)
                .equalTo('artifactId', artifactId)
                .orderBy('createTimestamp', 'desc');
            const snapshot = await this.client.executeQuery(query);
            let comments = [];
            while (snapshot.hasNext()) {
                const item = snapshot.next();
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
            return comments;
        }
        catch (err) {
            console.error('获取评论列表失败:', err);
            throw {
                code: err.code || 500,
                message: err.message || '获取评论列表失败'
            };
        }
    }
}
exports.ArtifactService = ArtifactService;
