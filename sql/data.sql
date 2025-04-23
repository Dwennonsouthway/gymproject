INSERT INTO users (
    username, password, name, email, birthday, address, phone, gender, weight, height, avatar, role, reset_token, membership_level
) VALUES
('user001', '124444', N'王小明', 'user001@example.com', '1995-06-15', N'台北市中正區', '0912345678', N'男', 70.5, 175, '/uploads/images/5de670ab-c895-4f43-bf67-8dfbaebdd228.JPG', 'USER', NULL, 'basic'),
('user002', '333333', N'李美麗', 'user002@example.com', '1992-11-22', N'新北市新店區', '0923456789', N'女', 55.2, 162, '/uploads/images/582f5032-adcf-47c6-8ae2-f835c44907f6.JPG', 'USER', NULL, 'basic'),
('user003', '1234', N'張大強', 'user003@example.com', '1988-04-10', N'台中市西區', '0934567890', N'男', 80.3, 180.5, '/uploads/images/0cb4f749-4bab-46ba-a4a9-1897f46b8f65.JPG', 'USER', NULL, 'basic'),
('user004', 'password4', N'陳小芳', 'user004@example.com', '1997-08-25', N'高雄市三民區', '0945678901', N'女', 48.7, 158.3, 'https://randomuser.me/api/portraits/women/5.jpg', 'USER', NULL, 'basic'),
('admin', 'password20', N'陳美美', '1212111', '2002-07-15', N'新北市板橋區', '0921234567', N'女', 56.1, 164.8, '/uploads/images/347aab10-b781-4c76-8004-f69d4bf67c6b.JPG', 'ADMIN', NULL, 'basic');


INSERT INTO Posts (UserID, Content, LikesCount, CommentsCount, ReviewStatus, ReportReason, ReportedBy)
VALUES
(1000, N'今天心情很好，來運動一下！', 5, 2, NULL, NULL, NULL),
(1001, N'剛加入健身房，希望可以持之以恆💪', 8, 3, NULL, NULL, NULL),
(1002, N'有人想一起報瑜伽課嗎？', 2, 0, NULL, NULL, NULL),
(1000, N'請問大家比較推薦自由重量還是機械式訓練？', 1, 1, N'pending', N'內容可能涉及廣告', 1003);


INSERT INTO post_images (post_id, image_url)
VALUES
(1, 'https://images.pexels.com/photos/1552242/pexels-photo-1552242.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2'),
(2, 'https://images.pexels.com/photos/1954524/pexels-photo-1954524.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2'),
(2, 'https://images.pexels.com/photos/1229356/pexels-photo-1229356.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2'),
(3, 'https://images.pexels.com/photos/917732/pexels-photo-917732.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2'),
(4, 'https://images.pexels.com/photos/949126/pexels-photo-949126.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2');