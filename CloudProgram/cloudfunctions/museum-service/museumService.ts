/// <reference types="node" />

import * as dbServer from '@agconnect/database-server';

// 数据模型接口
interface Museum {
    id: string;
    name: string;
    location: string;
    description: string;
    imageUrl: string;
    openingHours: string;
    ticketPrice: string;
    contactInfo: string;
    latitude: number;
    longitude: number;
    rating: number;
    artifactCount: number;
}

interface MuseumEvent {
    id: string;
    museumId: string;
    title: string;
    description: string;
    startDate: string;
    endDate: string;
    imageUrl: string;
    status: number; // 0-未开始 1-进行中 2-已结束
}

interface CloudDBError {
    code: number;
    message: string;
}

export class MuseumService {
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
     * 获取博物馆列表，支持分页和位置筛选
     */
    async getMuseumList(params: { page?: number; pageSize?: number; location?: string }) {
        await this.initClient();

        try {
            const { page = 1, pageSize = 10, location } = params;
            const Class = require('./Museum.js').default;

            // 创建查询
            const query = this.client.query(Class);
            if (location) {
                query.contains('location', location);
            }

            // 计算总数
            const countQuery = this.client.query(Class);
            if (location) {
                countQuery.contains('location', location);
            }
            const totalCount = await this.client.count(countQuery);

            // 设置分页
            const startIndex = (page - 1) * pageSize;
            query.limit(pageSize).skip(startIndex);

            // 执行查询
            const snapshot = await this.client.executeQuery(query);
            let museums: Museum[] = [];
            while (snapshot.hasNext()) {
                const item = snapshot.next();
                museums.push({
                    id: item.getId(),
                    name: item.getName(),
                    location: item.getLocation(),
                    description: item.getDescription(),
                    imageUrl: item.getImageUrl(),
                    openingHours: item.getOpeningHours(),
                    ticketPrice: item.getTicketPrice(),
                    contactInfo: item.getContactInfo(),
                    latitude: item.getLatitude(),
                    longitude: item.getLongitude(),
                    rating: item.getRating(),
                    artifactCount: item.getArtifactCount()
                });
            }

            // 关闭查询结果
            snapshot.release();

            return { museums, totalCount };
        } catch (err) {
            console.error('获取博物馆列表失败:', err);
            throw {
                code: (err as CloudDBError).code || 500,
                message: (err as CloudDBError).message || '获取博物馆列表失败'
            };
        }
    }

    /**
     * 获取博物馆详情
     */
    async getMuseumDetail(museumId: string) {
        await this.initClient();

        try {
            const Class = require('./Museum.js').default;

            // 创建查询
            const query = this.client.query(Class).equalTo('id', museumId);
            const snapshot = await this.client.executeQuery(query);

            if (snapshot.hasNext()) {
                const item = snapshot.next();
                const museum: Museum = {
                    id: item.getId(),
                    name: item.getName(),
                    location: item.getLocation(),
                    description: item.getDescription(),
                    imageUrl: item.getImageUrl(),
                    openingHours: item.getOpeningHours(),
                    ticketPrice: item.getTicketPrice(),
                    contactInfo: item.getContactInfo(),
                    latitude: item.getLatitude(),
                    longitude: item.getLongitude(),
                    rating: item.getRating(),
                    artifactCount: item.getArtifactCount()
                };

                // 关闭查询结果
                snapshot.release();
                return museum;
            } else {
                // 关闭查询结果
                snapshot.release();
                throw {
                    code: 404,
                    message: '博物馆不存在'
                };
            }
        } catch (err) {
            console.error('获取博物馆详情失败:', err);
            throw {
                code: (err as CloudDBError).code || 500,
                message: (err as CloudDBError).message || '获取博物馆详情失败'
            };
        }
    }

    /**
     * 获取博物馆活动列表
     */
    async getMuseumEvents(museumId: string) {
        await this.initClient();

        try {
            const Class = require('./MuseumEvent.js').default;

            // 创建查询
            const query = this.client.query(Class).equalTo('museumId', museumId);
            const snapshot = await this.client.executeQuery(query);

            let events: MuseumEvent[] = [];
            while (snapshot.hasNext()) {
                const item = snapshot.next();
                events.push({
                    id: item.getId(),
                    museumId: item.getMuseumId(),
                    title: item.getTitle(),
                    description: item.getDescription(),
                    startDate: item.getStartDate(),
                    endDate: item.getEndDate(),
                    imageUrl: item.getImageUrl(),
                    status: item.getStatus()
                });
            }

            // 关闭查询结果
            snapshot.release();
            return events;
        } catch (err) {
            console.error('获取博物馆活动列表失败:', err);
            throw {
                code: (err as CloudDBError).code || 500,
                message: (err as CloudDBError).message || '获取博物馆活动列表失败'
            };
        }
    }

    /**
     * 搜索博物馆
     */
    async searchMuseums(keyword: string) {
        await this.initClient();

        try {
            const Class = require('./Museum.js').default;

            // 创建多条件搜索
            const nameQuery = this.client.query(Class).contains('name', keyword);
            const locationQuery = this.client.query(Class).contains('location', keyword);
            const descQuery = this.client.query(Class).contains('description', keyword);

            // 组合查询
            const combinedQuery = this.client.queryBuilder()
                .or(nameQuery, locationQuery, descQuery)
                .build();

            // 执行查询
            const snapshot = await this.client.executeQuery(combinedQuery);

            let museums: Museum[] = [];
            while (snapshot.hasNext()) {
                const item = snapshot.next();
                museums.push({
                    id: item.getId(),
                    name: item.getName(),
                    location: item.getLocation(),
                    description: item.getDescription(),
                    imageUrl: item.getImageUrl(),
                    openingHours: item.getOpeningHours(),
                    ticketPrice: item.getTicketPrice(),
                    contactInfo: item.getContactInfo(),
                    latitude: item.getLatitude(),
                    longitude: item.getLongitude(),
                    rating: item.getRating(),
                    artifactCount: item.getArtifactCount()
                });
            }

            // 关闭查询结果
            snapshot.release();
            return { museums };
        } catch (err) {
            console.error('搜索博物馆失败:', err);
            throw {
                code: (err as CloudDBError).code || 500,
                message: (err as CloudDBError).message || '搜索博物馆失败'
            };
        }
    }
} 