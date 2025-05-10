/**
 * 数据初始化工具
 */
const db = require('../models');
const Artifact = db.artifacts;
const User = db.users;

/**
 * 初始化示例数据
 */
async function initSampleData() {
    try {
        // 检查是否已有数据
        const artifactsCount = await Artifact.count();
        const usersCount = await User.count();

        console.log(`数据库中已有 ${artifactsCount} 个文物和 ${usersCount} 个用户。`);

        // 如果已有数据则跳过
        if (artifactsCount > 0 && usersCount > 0) {
            console.log('数据库中已有数据，跳过初始化。');
            return;
        }

        console.log('开始初始化示例数据...');

        // 创建示例用户
        if (usersCount === 0) {
            await User.create({
                id: '1',
                username: 'admin',
                password: 'admin123',
                email: 'admin@example.com',
                avatarUrl: 'https://example.com/avatar1.jpg',
                isVerified: true
            });

            await User.create({
                id: '2',
                username: 'user',
                password: 'user123',
                email: 'user@example.com',
                avatarUrl: 'https://example.com/avatar2.jpg',
                isVerified: true
            });

            console.log('已创建示例用户。');
        }

        // 创建示例文物
        if (artifactsCount === 0) {
            await Artifact.create({
                id: '1',
                name: '青铜鼎',
                era: '春秋战国',
                museum: '中国国家博物馆',
                description: '青铜鼎是中国古代青铜礼器，是中国古代政治权力和社会地位的象征。这件青铜鼎形制宏大，纹饰精美，是春秋战国时期的代表性器物。',
                imageUrl: 'https://example.com/artifact1.jpg',
                categoryId: 1,
                detailUrl: 'https://example.com/detail1',
                likes: 150,
                comments: 42
            });

            await Artifact.create({
                id: '2',
                name: '唐三彩马',
                era: '唐代',
                museum: '陕西历史博物馆',
                description: '唐三彩是唐代特有的彩釉陶器，以黄、绿、白三色为主。这件唐三彩马栩栩如生，展现了唐代陶瓷工艺的高超水平。',
                imageUrl: 'https://example.com/artifact2.jpg',
                categoryId: 2,
                detailUrl: 'https://example.com/detail2',
                likes: 230,
                comments: 56
            });

            await Artifact.create({
                id: '3',
                name: '清明上河图',
                era: '北宋',
                museum: '故宫博物院',
                description: '《清明上河图》是北宋张择端创作的作品，全卷长528.7厘米，宽24.8厘米，描绘了北宋京城汴梁的繁华景象。',
                imageUrl: 'https://example.com/artifact3.jpg',
                categoryId: 3,
                detailUrl: 'https://example.com/detail3',
                likes: 500,
                comments: 120
            });

            await Artifact.create({
                id: '4',
                name: '莫高窟壁画',
                era: '魏晋至元代',
                museum: '敦煌研究院',
                description: '敦煌莫高窟是中国石窟艺术的瑰宝，现存洞窟492个，壁画面积45000多平方米，是世界上规模最大的佛教艺术宝库。',
                imageUrl: 'https://example.com/artifact4.jpg',
                categoryId: 4,
                detailUrl: 'https://example.com/detail4',
                likes: 320,
                comments: 87
            });

            await Artifact.create({
                id: '5',
                name: '越王勾践剑',
                era: '春秋晚期',
                museum: '湖北省博物馆',
                description: '越王勾践剑是中国出土的最著名的青铜剑之一，保存完好，锋利无比，是中国古代冶金、铸造和制剑技术的杰出代表。',
                imageUrl: 'https://example.com/artifact5.jpg',
                categoryId: 1,
                detailUrl: 'https://example.com/detail5',
                likes: 410,
                comments: 93
            });

            console.log('已创建示例文物。');
        }

        console.log('示例数据初始化完成。');
    } catch (error) {
        console.error('初始化示例数据失败:', error);
    }
}

module.exports = { initSampleData }; 