/// <reference types="node" />

import * as dbServer from '@agconnect/database-server';

// 数据模型接口
interface Artifact {
    id: string;
    name: string;
    era: string;
    museum: string;
    description: string;
    imageUrl: string;
    categoryId: number;
    detailUrl: string;
    likes: number;
    comments: number;
}

interface Comment {
    id: string;
    artifactId: string;
    userId: string;
    username: string;
    avatarUrl: string;
    content: string;
    createTime: string;
    createTimestamp: Date;
}

interface CloudDBError {
    code: number;
    message: string;
}

// 添加类型定义
type ArtifactClass = {
    default: any;
};

type CommentClass = {
    default: any;
};

export class ArtifactService {
    private client: any; // 使用any类型避免类型错误
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
            // 使用正确的API初始化数据库
            const db = dbServer.initializeApp();
            this.client = db.cloudDB().openZone(this.zoneName);
            this.isInitialized = true;
            console.log('CloudDB客户端初始化成功');
        } catch (err) {
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
    async getArtifactList(params: { categoryId?: number; page?: number; pageSize?: number }) {
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
            let artifacts: Artifact[] = [];
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
        } catch (err) {
            console.error('获取文物列表失败:', err);
            throw {
                code: (err as CloudDBError).code || 500,
                message: (err as CloudDBError).message || '获取文物列表失败'
            };
        }
    }

    /**
     * 获取文物详情
     */
    async getArtifactDetail(artifactId: string) {
        await this.initClient();

        try {
            const Class = require('./Artifact.js').default;

            // 创建查询
            const query = this.client.query(Class).equalTo('id', artifactId);
            const snapshot = await this.client.executeQuery(query);

            if (snapshot.hasNext()) {
                const item = snapshot.next();
                const artifact: Artifact = {
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
            } else {
                // 关闭查询结果
                snapshot.release();
                throw {
                    code: 404,
                    message: '文物不存在'
                };
            }
        } catch (err) {
            console.error('获取文物详情失败:', err);
            throw {
                code: (err as CloudDBError).code || 500,
                message: (err as CloudDBError).message || '获取文物详情失败'
            };
        }
    }

    /**
     * 关键词搜索文物
     */
    async searchArtifacts(keyword: string) {
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
            let artifacts: Artifact[] = [];

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
        } catch (err) {
            console.error('搜索文物失败:', err);
            throw {
                code: (err as CloudDBError).code || 500,
                message: (err as CloudDBError).message || '搜索文物失败'
            };
        }
    }

    /**
     * 获取文物评论列表
     */
    async getArtifactComments(artifactId: string) {
        await this.initClient();

        try {
            const CommentClass = require('./Comment.js').default;

            // 创建查询
            const query = this.client.query(CommentClass)
                .equalTo('artifactId', artifactId)
                .orderBy('createTimestamp', 'desc');

            const snapshot = await this.client.executeQuery(query);
            let comments: Comment[] = [];

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
        } catch (err) {
            console.error('获取评论列表失败:', err);
            throw {
                code: (err as CloudDBError).code || 500,
                message: (err as CloudDBError).message || '获取评论列表失败'
            };
        }
    }
} 