/// <reference types="node" />

import * as dbServer from '@agconnect/database-server';

// 数据模型接口
interface Comment {
    id: string;
    artifactId: string;
    userId: string;
    username: string;
    avatarUrl: string;
    content: string;
    createTime: string;
    likes: number;
}

interface CommentLike {
    commentId: string;
    userId: string;
    likeTime: string;
}

interface CloudDBError {
    code: number;
    message: string;
}

export class CommentService {
    private client: any;
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
            // 使用华为云API初始化数据库
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
     * 获取文物的评论列表
     */
    async getComments(params: { artifactId: string; page?: number; pageSize?: number }) {
        await this.initClient();

        try {
            const { artifactId, page = 1, pageSize = 10 } = params;
            const Class = require('./Comment.js').default;

            // 创建查询
            const query = this.client.query(Class).equalTo('artifactId', artifactId);

            // 计算总数
            const totalCount = await this.client.count(query);

            // 设置分页和排序
            const startIndex = (page - 1) * pageSize;
            query.orderBy('createTime', true).limit(pageSize).skip(startIndex);

            // 执行查询
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
                    likes: item.getLikes()
                });
            }

            // 关闭查询结果
            snapshot.release();

            return { comments, totalCount };
        } catch (err) {
            console.error('获取评论列表失败:', err);
            throw {
                code: (err as CloudDBError).code || 500,
                message: (err as CloudDBError).message || '获取评论列表失败'
            };
        }
    }

    /**
     * 添加评论
     */
    async addComment(params: { artifactId: string; userId: string; username: string; avatarUrl: string; content: string }) {
        await this.initClient();

        try {
            const { artifactId, userId, username, avatarUrl, content } = params;

            // 生成评论ID
            const commentId = `CMT_${Date.now()}_${Math.floor(Math.random() * 10000)}`;

            // 创建评论对象
            const CommentClass = require('./Comment.js').default;
            const comment = new CommentClass();
            comment.setId(commentId);
            comment.setArtifactId(artifactId);
            comment.setUserId(userId);
            comment.setUsername(username);
            comment.setAvatarUrl(avatarUrl);
            comment.setContent(content);
            comment.setCreateTime(new Date().toISOString());
            comment.setLikes(0);

            // 保存评论
            await this.client.executeUpsert(comment);

            // 更新文物评论数
            await this.updateArtifactCommentCount(artifactId, 1);

            return {
                commentId,
                createTime: comment.getCreateTime()
            };
        } catch (err) {
            console.error('添加评论失败:', err);
            throw {
                code: (err as CloudDBError).code || 500,
                message: (err as CloudDBError).message || '添加评论失败'
            };
        }
    }

    /**
     * 删除评论
     */
    async deleteComment(params: { commentId: string; userId: string }) {
        await this.initClient();

        try {
            const { commentId, userId } = params;

            // 查询评论
            const CommentClass = require('./Comment.js').default;
            const query = this.client.query(CommentClass).equalTo('id', commentId);
            const snapshot = await this.client.executeQuery(query);

            if (!snapshot.hasNext()) {
                snapshot.release();
                throw {
                    code: 404,
                    message: '评论不存在'
                };
            }

            const comment = snapshot.next();

            // 检查是否是评论作者
            if (comment.getUserId() !== userId) {
                snapshot.release();
                throw {
                    code: 403,
                    message: '没有权限删除该评论'
                };
            }

            const artifactId = comment.getArtifactId();

            // 删除评论
            await this.client.executeDelete(comment);
            snapshot.release();

            // 更新文物评论数
            await this.updateArtifactCommentCount(artifactId, -1);

            return { success: true };
        } catch (err) {
            console.error('删除评论失败:', err);
            throw {
                code: (err as CloudDBError).code || 500,
                message: (err as CloudDBError).message || '删除评论失败'
            };
        }
    }

    /**
     * 点赞/取消点赞评论
     */
    async toggleLikeComment(params: { commentId: string; userId: string }) {
        await this.initClient();

        try {
            const { commentId, userId } = params;

            // 检查是否已点赞
            const isLiked = await this.checkCommentLiked(commentId, userId);

            if (isLiked) {
                // 取消点赞
                await this.removeCommentLike(commentId, userId);
                await this.updateCommentLikeCount(commentId, -1);
                return {
                    success: true,
                    action: 'unlike'
                };
            } else {
                // 添加点赞
                await this.addCommentLike(commentId, userId);
                await this.updateCommentLikeCount(commentId, 1);
                return {
                    success: true,
                    action: 'like'
                };
            }
        } catch (err) {
            console.error('点赞/取消点赞评论失败:', err);
            throw {
                code: (err as CloudDBError).code || 500,
                message: (err as CloudDBError).message || '操作评论点赞失败'
            };
        }
    }

    /**
     * 检查用户是否已点赞评论
     */
    private async checkCommentLiked(commentId: string, userId: string): Promise<boolean> {
        const LikeClass = require('./CommentLike.js').default;
        const query = this.client.query(LikeClass)
            .equalTo('commentId', commentId)
            .equalTo('userId', userId);

        const count = await this.client.count(query);
        return count > 0;
    }

    /**
     * 添加评论点赞
     */
    private async addCommentLike(commentId: string, userId: string) {
        const LikeClass = require('./CommentLike.js').default;
        const like = new LikeClass();
        like.setCommentId(commentId);
        like.setUserId(userId);
        like.setLikeTime(new Date().toISOString());

        await this.client.executeUpsert(like);
    }

    /**
     * 移除评论点赞
     */
    private async removeCommentLike(commentId: string, userId: string) {
        const LikeClass = require('./CommentLike.js').default;
        const query = this.client.query(LikeClass)
            .equalTo('commentId', commentId)
            .equalTo('userId', userId);

        const snapshot = await this.client.executeQuery(query);

        if (snapshot.hasNext()) {
            const item = snapshot.next();
            await this.client.executeDelete(item);
        }

        snapshot.release();
    }

    /**
     * 更新评论点赞数
     */
    private async updateCommentLikeCount(commentId: string, delta: number) {
        const CommentClass = require('./Comment.js').default;
        const query = this.client.query(CommentClass).equalTo('id', commentId);
        const snapshot = await this.client.executeQuery(query);

        if (snapshot.hasNext()) {
            const comment = snapshot.next();
            const currentLikes = comment.getLikes() || 0;
            comment.setLikes(Math.max(0, currentLikes + delta));
            await this.client.executeUpsert(comment);
        }

        snapshot.release();
    }

    /**
     * 更新文物评论数量
     */
    private async updateArtifactCommentCount(artifactId: string, delta: number) {
        try {
            const ArtifactClass = require('./Artifact.js').default;
            const query = this.client.query(ArtifactClass).equalTo('id', artifactId);
            const snapshot = await this.client.executeQuery(query);

            if (snapshot.hasNext()) {
                const artifact = snapshot.next();
                const currentComments = artifact.getComments() || 0;
                artifact.setComments(Math.max(0, currentComments + delta));
                await this.client.executeUpsert(artifact);
            }

            snapshot.release();
        } catch (err) {
            console.error('更新文物评论数量失败:', err);
            // 不中断主流程，仅记录错误
        }
    }
} 