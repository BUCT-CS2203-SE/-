/**
 * 用户控制器
 */
const db = require("../models");
const User = db.User;
const RelicComment = db.RelicComment;
const RelicFavorite = db.RelicFavorite;
const Artifact = db.Artifact;
const { Op } = db.Sequelize;
const bcrypt = require('bcrypt');

// 用户注册
exports.register = async (req, res) => {
    try {
        // 验证请求
        if (!req.body.phone || !req.body.password) {
            return res.status(400).send({
                message: "手机号和密码不能为空！"
            });
        }

        // 检查手机号是否已存在
        const existingUser = await User.findOne({ where: { phone: req.body.phone } });
        if (existingUser) {
            return res.status(400).send({
                message: "手机号已存在！"
            });
        }

        // 哈希处理密码
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(req.body.password, salt);

        // 创建用户对象
        const user = {
            nickname: req.body.nickname || '用户',
            gender: req.body.gender || 0,
            phone: req.body.phone,
            password: hashedPassword, // 使用哈希后的密码
            email: req.body.email || "",
            img_url: req.body.img_url || "https://tse1-mm.cn.bing.net/th/id/OIP-C.3dLZ4NXxxg03pzV30ITasAAAAA?rs=1&pid=ImgDetMain",
            spare: req.body.spare || null
        };

        // 保存到数据库
        const data = await User.create(user);

        // 返回用户信息（不包含密码）
        const { password, ...userWithoutPassword } = data.toJSON();
        res.send(userWithoutPassword);
    } catch (err) {
        res.status(500).send({
            message: err.message || "用户注册时发生错误。"
        });
    }
};

// 用户登录
exports.login = async (req, res) => {
    try {
        // 验证请求
        if (!req.body.phone || !req.body.password) {
            return res.status(400).send({
                message: "手机号和密码不能为空！"
            });
        }

        // 查找用户
        const user = await User.findOne({ where: { phone: req.body.phone } });

        if (!user) {
            return res.status(404).send({
                message: `手机号 ${req.body.phone} 未注册！`
            });
        }

        // 验证密码
        const isPasswordValid = await bcrypt.compare(req.body.password, user.password);
        if (!isPasswordValid) {
            return res.status(401).send({
                message: "密码错误！"
            });
        }

        // 返回用户信息（不包含密码）
        const { password, ...userWithoutPassword } = user.toJSON();
        res.send({
            message: "登录成功！",
            user: userWithoutPassword
        });
    } catch (err) {
        console.error("登录错误:", err);
        res.status(500).send({
            message: err.message || "用户登录时发生错误。"
        });
    }
};

// 获取用户信息
exports.findOne = async (req, res) => {
    try {
        const id = req.params.id;

        const user = await User.findByPk(id);

        if (user) {
            // 返回用户信息（不包含密码）
            const { password, ...userWithoutPassword } = user.toJSON();
            res.send(userWithoutPassword);
        } else {
            res.status(404).send({
                message: `未找到ID为 ${id} 的用户。`
            });
        }
    } catch (err) {
        res.status(500).send({
            message: `获取ID为 ${req.params.id} 的用户信息时发生错误。`
        });
    }
};

// 更新用户信息
exports.update = async (req, res) => {
    try {
        const id = req.params.id;

        // 如果更新密码，应该在这里哈希处理

        const num = await User.update(req.body, {
            where: { id: id }
        });

        if (num == 1) {
            res.send({
                message: "用户信息更新成功。"
            });
        } else {
            res.send({
                message: `无法更新ID为 ${id} 的用户。可能用户不存在或请求体为空！`
            });
        }
    } catch (err) {
        res.status(500).send({
            message: `更新ID为 ${req.params.id} 的用户信息时发生错误。`
        });
    }
};

// 添加评论
exports.addComment = async (req, res) => {
    try {
        // 验证请求
        if (!req.body.artifactId || !req.body.userId || !req.body.content) {
            return res.status(400).send({
                message: "文物ID、用户ID和评论内容不能为空！"
            });
        }

        // 检查文物和用户是否存在
        const artifact = await Artifact.findByPk(req.body.artifactId);
        const user = await User.findByPk(req.body.userId);

        if (!artifact) {
            return res.status(404).send({
                message: `未找到ID为 ${req.body.artifactId} 的文物。`
            });
        }

        if (!user) {
            return res.status(404).send({
                message: `未找到ID为 ${req.body.userId} 的用户。`
            });
        }

        const now = new Date();

        // 创建评论对象
        const comment = {
            relic_id: parseInt(req.body.artifactId),
            user_id: req.body.userId,
            comment: req.body.content,
            comment_time: now
        };

        // 保存到数据库
        const data = await RelicComment.create(comment);

        res.send(data);
    } catch (err) {
        res.status(500).send({
            message: err.message || "添加评论时发生错误。"
        });
    }
};

// 获取用户评论
exports.getComments = async (req, res) => {
    try {
        const userId = req.params.id;

        // 通过关联查询方式获取评论
        const comments = await RelicComment.findAll({
            where: { user_id: userId },
            include: [
                {
                    model: Artifact,
                    as: 'relic'
                },
                {
                    model: User,
                    as: 'user'
                }
            ],
            order: [['comment_time', 'DESC']]
        });

        if (!comments) {
            return res.status(404).send({
                message: `未找到ID为 ${userId} 的用户评论。`
            });
        }

        res.send(comments);
    } catch (err) {
        res.status(500).send({
            message: err.message || `获取用户ID为 ${req.params.id} 的评论时发生错误。`
        });
    }
};

// 添加收藏
exports.addFavorite = async (req, res) => {
    try {
        // 验证请求
        if (!req.body.artifactId || !req.body.userId) {
            return res.status(400).send({
                message: "文物ID和用户ID不能为空！"
            });
        }

        // 检查是否已收藏
        const existingFavorite = await RelicFavorite.findOne({
            where: {
                user_id: req.body.userId,
                relic_id: parseInt(req.body.artifactId)
            }
        });

        if (existingFavorite) {
            return res.status(400).send({
                message: "已经收藏过该文物！"
            });
        }

        // 创建收藏对象
        const favorite = {
            user_id: req.body.userId,
            relic_id: parseInt(req.body.artifactId)
        };

        // 保存到数据库
        const data = await RelicFavorite.create(favorite);
        res.send(data);
    } catch (err) {
        res.status(500).send({
            message: err.message || "添加收藏时发生错误。"
        });
    }
};

// 取消收藏
exports.removeFavorite = async (req, res) => {
    try {
        const { userId, artifactId } = req.params;

        const num = await RelicFavorite.destroy({
            where: {
                user_id: userId,
                relic_id: parseInt(artifactId)
            }
        });

        if (num == 1) {
            res.send({
                message: "取消收藏成功！"
            });
        } else {
            res.send({
                message: `未找到用户ID为 ${userId} 对文物ID为 ${artifactId} 的收藏。`
            });
        }
    } catch (err) {
        res.status(500).send({
            message: err.message || "取消收藏时发生错误。"
        });
    }
};

// 获取用户收藏
exports.getFavorites = async (req, res) => {
    try {
        const userId = req.params.id;

        // 通过关联查询方式获取收藏
        const favorites = await RelicFavorite.findAll({
            where: { user_id: userId },
            include: [{
                model: Artifact,
                as: 'relic'
            }],
            order: [['fav_id', 'DESC']]
        });

        if (!favorites) {
            return res.status(404).send({
                message: `未找到ID为 ${userId} 的用户收藏。`
            });
        }

        // 提取文物对象
        const artifacts = favorites.map(favorite => favorite.relic).filter(Boolean);
        res.send(artifacts);
    } catch (err) {
        res.status(500).send({
            message: err.message || `获取用户ID为 ${req.params.id} 的收藏时发生错误。`
        });
    }
}; 