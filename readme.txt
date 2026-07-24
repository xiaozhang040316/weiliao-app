改动记录：

1. 修复圈子动态删除按钮无反应的问题
   - 在 CircleMomentsListLogic 中添加 deleteCircleMoment 方法，实现删除圈子动态功能
   - 在 CircleDetailLogic 中添加 deleteCircleMoment 方法，实现圈子详情页删除动态功能
   - 在圈子动态列表页面和圈子详情页面传递 delMoment 回调给 WorkMomentsItem 组件

2. 圈子成员列表显示封禁状态
   - 根据 isBanned 字段动态显示左滑操作按钮（封禁/解封），已封禁显示绿色解封按钮，未封禁显示红色封禁按钮
   - 如果成员被封禁，昵称颜色变为灰色（使用 Styles.ts_8E9AB0_16sp）
   - 被封禁成员昵称后面显示红色"已封禁"标签

3. 圈子成员列表头像改为圆形
   - 在 CircleMembersPage 的 AvatarView 组件中添加 isCircle: true 参数，使成员头像显示为圆形

4. 圈子详情页面和加入圈子页面优化
   - 圈子详情页面的圈子头像改为圆形（添加 isCircle: true 参数）
   - 加入圈子页面的加入按钮改为文字按钮（使用 TextButton 替代 Button 组件）
   - 加入圈子页面的搜索添加防抖功能（500ms 延迟），避免频繁调用搜索接口

5. 圈子页面铃铛图标优化
   - 将铃铛图标尺寸从 28.w 缩小到 22.w
   - 静音状态下显示白色圆形背景、黑色边框的图标样式，内部图标尺寸为 14.w

6. 消息页面圈子入口图标更换
   - 将消息页面圈子入口图标从 ImageRes.workingCircle 改为 ImageRes.circle（使用 circle.webp）
   - 修正 ImageRes.circle 的路径，从 ic_circle.webp 改为 circle.webp
   - 修复图标布局溢出问题，使用 ClipRect 包裹 Stack 组件

7. 圈子首页"我的圈子"文字大小调整
   - 将"我的圈子"文字大小从 16sp 改为 14sp，与"更多"文字大小保持一致

8. 修复好友信息页面 VIP 昵称显示问题
   - 在好友信息页面的昵称部分使用 Obx 包裹，确保能正确响应 userInfo.value.ex 的变化
   - 确保 VIP 等级和靓号标签能正确显示，与通讯录中的显示方式保持一致

9. 隐藏发现 tabbar
   - 在 HomePage 中注释掉 WorkbenchPage 和对应的 BottomBarItem，暂时隐藏"发现"（工作台）tab

10. 消息页面圈子入口图标改为圆形
   - 使用 ClipOval 包裹圈子入口图标，使其显示为圆形

11. 加入圈子功能支持邀请码
   - 更新 CircleInfo 模型，添加 inviteCodeNum 字段
   - 修改 joinCircle 接口，支持传递 inviteCodes 参数
   - 在点击"加入"按钮时，先获取圈子信息检查 inviteCodeNum
   - 如果 inviteCodeNum > 0，弹出输入邀请码对话框
   - 对话框根据 inviteCodeNum 动态生成对应数量的输入框
   - 每个输入框限制6位字符，自动转换为大写
   - 点击确定时验证所有邀请码已填写完整，然后传递给后端接口

12. 生成邀请码功能
   - 添加生成邀请码的 API 接口（generateInviteCode）
   - 在圈子详情页面添加"生成邀请码"按钮
   - 检查用户是否被封禁，如果被封禁则禁用生成邀请码按钮
   - 生成成功后显示邀请码对话框，用户可以复制邀请码

13. 消息页面导航栏显示用户昵称
   - 在消息页面导航栏左侧添加当前登录用户的昵称显示
   - 昵称显示在圈子图标和同步状态之间
   - 昵称支持单行显示，超出部分用省略号显示

14. 圈子详情页面显示邀请码数量和创建时间
   - 在圈子详情页面的圈子信息部分添加邀请码数量显示
   - 如果 inviteCodeNum > 0，显示"需要 X 张邀请码进圈"（橙色文字）
   - 显示圈子的创建时间，格式为"创建时间：YYYY年MM月dd日"（灰色文字）


