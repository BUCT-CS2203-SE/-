/**
 * 帖子控制器
 */
const db = require("../models");
// 添加调试日志
console.log('加载模型:', Object.keys(db));
console.log('Post模型:', db.Post ? '已加载' : '未加载', db.Post);
console.log('Comment模型:', db.Comment ? '已加载' : '未加载', db.Comment);

const { Post, Comment } = db;
const { Op } = require("sequelize");

// 创建帖子
exports.create = async (req, res) => {
    try {
        // 检查请求数据完整性
        if (!req.body.content || !req.body.user_id) {
            return res.status(400).json({
                message: "帖子内容和用户ID不能为空",
                code: "INVALID_INPUT"
            });
        }

        // 精确采集前端提交的所有字段
        const post = await Post.create({
            post_id: req.body.post_id,
            content: req.body.content,
            post_img_url: req.body.post_img_url,
            user_id: req.body.user_id,
            nickname: req.body.nickname,
            img_url: req.body.img_url,
            create_time: req.body.create_time,
            create_timestamp: req.body.create_timestamp
        });

        // 成功状态码明确设置为201，返回新创建的完整帖子对象
        res.status(201).json({
            message: "帖子创建成功",
            data: post
        });
    } catch (error) {
        console.error('创建帖子失败:', error);

        // 更详细的错误处理
        if (error.name === 'SequelizeConnectionError' ||
            error.name === 'SequelizeConnectionRefusedError' ||
            error.name === 'SequelizeHostNotFoundError' ||
            error.name === 'SequelizeHostNotReachableError') {
            return res.status(503).json({
                message: "数据库连接失败，请检查网络连接",
                error: "NETWORK_ERROR",
                details: error.message
            });
        }

        // 数据验证错误
        if (error.name === 'SequelizeValidationError' || error.name === 'SequelizeUniqueConstraintError') {
            return res.status(400).json({
                message: "数据验证失败",
                error: "VALIDATION_ERROR",
                details: error.message
            });
        }

        res.status(500).json({
            message: "创建帖子失败",
            error: "SERVER_ERROR",
            details: error.message
        });
    }
};

// 获取帖子列表（分页）
exports.findAll = async (req, res) => {
    try {
        // 调试日志
        console.log('db对象:', Object.keys(db));
        console.log('Post模型状态:', db.Post ? '存在' : '不存在');
        console.log('Post对象详情:', db.Post);

        // 默认值设置
        const { keyword, page = 1, pageSize = 10 } = req.query;
        const offset = (page - 1) * pageSize;

        // 查询过程完整记录日志
        console.log('查询参数:', { keyword, page, pageSize, offset });

        // 构建查询条件（仅当有关键词时）
        const where = {};
        if (keyword) {
            where[Op.or] = [
                { content: { [Op.like]: `%${keyword}%` } }
            ];
        }

        console.log('查询条件:', where);

        // 查询帖子列表
        const { count, rows } = await Post.findAndCountAll({
            where,
            // 精确字段筛选
            attributes: [
                'post_id',
                'content',
                'post_img_url',
                'likes',
                'is_favorited',
                'user_id',
                'nickname',
                'img_url',
                'create_time',
                'create_timestamp'
            ],
            // 评论关联加载
            include: [{
                model: Comment,
                as: 'comments',
                required: false, // 确保不过滤没有评论的帖子
                attributes: [
                    'comment_id',
                    'post_id',
                    'user_id',
                    'nickname',
                    'img_url',
                    'content',
                    'create_time',
                    'create_timestamp'
                ]
            }],
            // 使用类型转换
            limit: parseInt(pageSize),
            offset: parseInt(offset),
            order: [['create_timestamp', 'DESC']]
        });

        console.log('查询结果:', { count, rowsCount: rows.length });

        // 空结果特殊处理
        if (count === 0) {
            return res.json({
                total: 0,
                currentPage: parseInt(page),
                pageSize: parseInt(pageSize),
                data: []
            });
        }

        res.json({
            total: count,
            currentPage: parseInt(page),
            pageSize: parseInt(pageSize),
            data: rows
        });
    } catch (error) {
        console.error('获取帖子列表失败:', error);

        // 数据库连接错误特殊处理
        if (error.name === 'SequelizeConnectionError' ||
            error.name === 'SequelizeConnectionRefusedError' ||
            error.name === 'SequelizeHostNotFoundError' ||
            error.name === 'SequelizeHostNotReachableError') {
            return res.status(503).json({
                message: "数据库连接失败，请检查网络连接",
                error: "NETWORK_ERROR",
                details: error.message
            });
        }

        res.status(500).json({
            message: "获取帖子列表失败",
            error: "SERVER_ERROR",
            details: error.message
        });
    }
};

// 获取所有帖子（不分页）
exports.getAll = async (req, res) => {
    try {
        // 不包含分页参数处理，简化的关联加载
        const posts = await Post.findAll({
            include: [{
                model: Comment,
                as: 'comments'
            }],
            order: [['create_timestamp', 'DESC']]
        });

        res.json({
            message: "获取帖子列表成功",
            data: posts
        });
    } catch (error) {
        console.error('获取帖子列表失败:', error);
        res.status(500).json({
            message: "获取帖子列表失败",
            error: error.message
        });
    }
};

// 获取单个帖子
exports.findOne = async (req, res) => {
    try {
        // 使用主键查询，加载关联评论并按时间排序
        const post = await Post.findByPk(req.params.id, {
            include: [{
                model: Comment,
                as: 'comments',
                order: [['create_timestamp', 'DESC']]
            }]
        });

        // 找不到帖子时返回404
        if (!post) {
            return res.status(404).json({
                message: "未找到该帖子"
            });
        }

        res.json(post);
    } catch (error) {
        console.error('获取帖子详情失败:', error);

        // 数据库连接错误特殊处理
        if (error.name === 'SequelizeConnectionError' ||
            error.name === 'SequelizeConnectionRefusedError' ||
            error.name === 'SequelizeHostNotFoundError' ||
            error.name === 'SequelizeHostNotReachableError') {
            return res.status(503).json({
                message: "数据库连接失败，请检查网络连接",
                error: "NETWORK_ERROR",
                details: error.message
            });
        }

        res.status(500).json({
            message: "获取帖子详情失败",
            error: "SERVER_ERROR",
            details: error.message
        });
    }
};

// 更新帖子
exports.update = async (req, res) => {
    try {
        // 先查询确认帖子存在
        const post = await Post.findByPk(req.params.id);
        if (!post) {
            return res.status(404).json({
                message: "未找到该帖子"
            });
        }

        // 只更新允许的字段
        await post.update({
            content: req.body.content,
            post_img_url: req.body.post_img_url,
            likes: req.body.likes,
            is_favorited: req.body.is_favorited
        });

        // 返回更新后的完整帖子对象
        res.json({
            message: "帖子更新成功",
            data: post
        });
    } catch (error) {
        console.error('更新帖子失败:', error);
        res.status(500).json({
            message: "更新帖子失败",
            error: error.message
        });
    }
};

// 删除帖子
exports.delete = async (req, res) => {
    try {
        const post = await Post.findByPk(req.params.id);
        if (!post) {
            return res.status(404).json({
                message: "未找到该帖子"
            });
        }

        // 使用实例方法删除
        await post.destroy();

        // 成功删除仅返回成功消息
        res.json({
            message: "帖子删除成功"
        });
    } catch (error) {
        console.error('删除帖子失败:', error);
        res.status(500).json({
            message: "删除帖子失败",
            error: error.message
        });
    }
};

// 获取帖子评论
exports.getComments = async (req, res) => {
    try {
        // 路径参数明确命名
        const postId = req.params.id;

        const post = await Post.findByPk(postId, {
            include: [{
                model: Comment,
                as: 'comments',
                order: [['create_timestamp', 'DESC']]
            }]
        });

        if (!post) {
            return res.status(404).json({
                message: `未找到ID为 ${postId} 的帖子。`
            });
        }

        // 返回空数组而非null
        res.json(post.comments || []);
    } catch (error) {
        console.error('获取帖子评论失败:', error);
        res.status(500).json({
            message: "获取帖子评论失败",
            error: error.message
        });
    }
};

// 更新帖子点赞数
exports.updateLikes = async (req, res) => {
    try {
        const post = await Post.findByPk(req.params.id);
        if (!post) {
            return res.status(404).json({
                message: "未找到该帖子"
            });
        }

        // 递增逻辑
        const newLikes = post.likes + 1;
        // 仅更新likes字段
        await post.update({
            likes: newLikes
        });

        // 返回更新后的点赞数
        res.json({
            message: "点赞成功",
            data: {
                likes: newLikes
            }
        });
    } catch (error) {
        console.error('更新点赞数失败:', error);
        res.status(500).json({
            message: "更新点赞数失败",
            error: error.message
        });
    }
};

// 更新帖子收藏状态
exports.updateFavorite = async (req, res) => {
    try {
        // 极其详细的日志记录
        console.log('收到收藏状态更新请求:', {
            postId: req.params.id,
            body: req.body
        });

        const post = await Post.findByPk(req.params.id);
        if (!post) {
            console.log('未找到帖子:', req.params.id);
            return res.status(404).json({
                message: "未找到该帖子"
            });
        }

        console.log('当前帖子状态:', {
            postId: post.post_id,
            currentFavorite: post.is_favorited
        });

        // 布尔转数字转换
        const newFavoriteValue = req.body.is_favorited ? 1 : 0;

        console.log('尝试更新收藏状态:', {
            postId: req.params.id,
            newValue: newFavoriteValue
        });

        // 使用批量更新API
        const [updatedRows] = await Post.update(
            { is_favorited: newFavoriteValue },
            {
                where: { post_id: req.params.id }
            }
        );

        console.log('更新结果:', {
            updatedRows,
            postId: req.params.id
        });

        // 检查受影响行数
        if (updatedRows === 0) {
            console.log('没有行被更新');
            return res.status(404).json({
                message: "更新收藏状态失败"
            });
        }

        // 再次查询以获取最新状态
        const updatedPost = await Post.findByPk(req.params.id);
        console.log('更新后的帖子状态:', {
            postId: updatedPost.post_id,
            newFavorite: updatedPost.is_favorited
        });

        // 返回时数字转布尔
        res.json({
            message: "收藏状态更新成功",
            data: {
                is_favorited: updatedPost.is_favorited === 1
            }
        });
    } catch (error) {
        console.error('更新收藏状态失败:', error);
        res.status(500).json({
            message: "更新收藏状态失败",
            error: error.message
        });
    }
};

// 取消点赞
exports.unlike = async (req, res) => {
    try {
        const post = await Post.findByPk(req.params.id);
        if (!post) {
            return res.status(404).json({
                message: "未找到该帖子"
            });
        }

        // 防止负值
        const newLikes = Math.max(0, post.likes - 1);
        // 只更新点赞计数字段
        await post.update({
            likes: newLikes
        });

        // 返回与点赞增加操作一致的数据结构
        res.json({
            message: "取消点赞成功",
            data: {
                likes: newLikes
            }
        });
    } catch (error) {
        console.error('取消点赞失败:', error);
        res.status(500).json({
            message: "取消点赞失败",
            error: error.message
        });
    }
};

// 取消收藏
exports.unfavorite = async (req, res) => {
    try {
        console.log('收到取消收藏请求:', {
            postId: req.params.id
        });

        const post = await Post.findByPk(req.params.id);
        if (!post) {
            console.log('未找到帖子:', req.params.id);
            return res.status(404).json({
                message: "未找到该帖子"
            });
        }

        console.log('当前帖子状态:', {
            postId: post.post_id,
            currentFavorite: post.is_favorited
        });

        console.log('尝试更新收藏状态为0:', {
            postId: req.params.id
        });

        // 与updateFavorite极为相似，但直接硬编码值0
        const [updatedRows] = await Post.update(
            { is_favorited: 0 },
            {
                where: { post_id: req.params.id }
            }
        );

        console.log('更新结果:', {
            updatedRows,
            postId: req.params.id
        });

        if (updatedRows === 0) {
            console.log('没有行被更新');
            return res.status(404).json({
                message: "取消收藏失败"
            });
        }

        const updatedPost = await Post.findByPk(req.params.id);
        console.log('更新后的帖子状态:', {
            postId: updatedPost.post_id,
            newFavorite: updatedPost.is_favorited
        });

        // 返回固定布尔值false
        res.json({
            message: "取消收藏成功",
            data: {
                is_favorited: false
            }
        });
    } catch (error) {
        console.error('取消收藏失败:', error);
        res.status(500).json({
            message: "取消收藏失败",
            error: error.message
        });
    }
}; 