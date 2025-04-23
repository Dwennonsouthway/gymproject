CREATE TABLE users (
    id INT IDENTITY(1000,1) PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    name NVARCHAR(100) NOT NULL,
    email NVARCHAR(100) NOT NULL UNIQUE,
    birthday DATE NOT NULL,
    address NVARCHAR(255),
    phone NVARCHAR(20) NOT NULL,
    gender CHAR(2) NOT NULL,
    weight FLOAT,
    height FLOAT,
    avatar NVARCHAR(255),
    reset_token VARCHAR(255) NULL,
    role VARCHAR(10) NOT NULL DEFAULT 'USER',
    membership_level VARCHAR(20) NOT NULL DEFAULT 'basic'
);


-- 貼文主表
CREATE TABLE Posts (
    PostID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    Content NVARCHAR(MAX) NOT NULL,
    LikesCount INT DEFAULT 0,
    CommentsCount INT DEFAULT 0,
    Reported BIT DEFAULT 0 NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE(),
    ReviewStatus NVARCHAR(10) NULL,
    ReportReason NVARCHAR(500),
    ReportedBy INT,
    is_visible BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_Posts_Users FOREIGN KEY (UserID) 
        REFERENCES users(id) ON DELETE CASCADE
);

-- 貼文圖片表
CREATE TABLE post_images (
    post_id INT NOT NULL,
    image_url NVARCHAR(500) NULL,
    CONSTRAINT FK_PostImages_Posts FOREIGN KEY (post_id) 
        REFERENCES Posts(PostID) ON DELETE CASCADE
);

-- 貼文按讚表
CREATE TABLE PostLikes (
    id INT IDENTITY(1,1) PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    created_at DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT FK_PostLikes_Posts FOREIGN KEY (post_id) 
        REFERENCES Posts(PostID) ON DELETE CASCADE,
    CONSTRAINT FK_PostLikes_Users FOREIGN KEY (user_id) 
        REFERENCES users(id) 
);

-- 貼文按讚唯一索引
CREATE UNIQUE INDEX UX_PostLikes_PostUser 
ON PostLikes(post_id, user_id);

-- 留言表
CREATE TABLE Comments (
    CommentID INT IDENTITY(1,1) PRIMARY KEY,
    PostID INT NOT NULL,
    UserID INT NOT NULL,
    Content NVARCHAR(MAX) NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE() NOT NULL,
    UpdatedAt DATETIME DEFAULT GETDATE() NOT NULL,
    ParentCommentID INT,
    ReplyLevel INT DEFAULT 0,
    likes_count INT NOT NULL DEFAULT 0,
    CONSTRAINT FK_Comments_Posts FOREIGN KEY (PostID) 
        REFERENCES Posts(PostID) ON DELETE CASCADE,
    CONSTRAINT FK_Comments_Users FOREIGN KEY (UserID) 
        REFERENCES users(id) ,
    CONSTRAINT FK_Comments_ParentComment FOREIGN KEY (ParentCommentID) 
        REFERENCES Comments(CommentID)
);

-- 留言按讚表
CREATE TABLE CommentLikes (
    id INT IDENTITY(1,1) PRIMARY KEY,
    comment_id INT NOT NULL,
    user_id INT NOT NULL,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_CommentLikes_Comments FOREIGN KEY (comment_id) 
        REFERENCES Comments(CommentID) ON DELETE CASCADE,
    CONSTRAINT FK_CommentLikes_Users FOREIGN KEY (user_id) 
        REFERENCES users(id) 
);

-- 留言按讚索引
CREATE UNIQUE INDEX UX_CommentLikes_CommentUser 
ON CommentLikes(comment_id, user_id);

CREATE INDEX IX_CommentLikes_UserId 
ON CommentLikes(user_id);

CREATE INDEX IX_CommentLikes_CommentId 
ON CommentLikes(comment_id);

-- 通知表
CREATE TABLE notifications (
    notification_id INT IDENTITY(1,1) PRIMARY KEY,
    recipient_id INT NOT NULL,
    sender_id INT NOT NULL,
    post_id INT,
    comment_id INT,
    type VARCHAR(50) NOT NULL,
    content NVARCHAR(MAX) NOT NULL,
    is_read BIT DEFAULT 0,
    created_at DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT FK_notifications_recipient FOREIGN KEY (recipient_id) 
        REFERENCES users(id) ,
    CONSTRAINT FK_notifications_sender FOREIGN KEY (sender_id) 
        REFERENCES users(id),
    CONSTRAINT FK_notifications_post FOREIGN KEY (post_id) 
        REFERENCES posts(PostID) ON DELETE CASCADE,
    CONSTRAINT FK_notifications_comment FOREIGN KEY (comment_id) 
        REFERENCES comments(CommentID) 
);

-- 通知索引
CREATE NONCLUSTERED INDEX IX_notifications_recipient_created 
ON notifications(recipient_id, created_at DESC);

CREATE NONCLUSTERED INDEX IX_notifications_is_read 
ON notifications(is_read);

CREATE TABLE user_profiles (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    bio NVARCHAR(MAX),
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_UserProfiles_Users FOREIGN KEY (user_id) 
        REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX IX_UserProfiles_UserId ON user_profiles(user_id);


-- 1. 貼文按讚通知觸發器
CREATE TRIGGER TR_PostLikes_AddNotification
ON PostLikes
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO Notifications 
        (recipient_id, sender_id, post_id, type, content, is_read, created_at)
    SELECT 
        p.UserID,
        i.user_id,
        p.PostID,
        'like_post',
        (SELECT username FROM users WHERE id = i.user_id) + N' 對你的貼文按讚了',
        0,
        GETDATE()
    FROM inserted i
    INNER JOIN Posts p ON i.post_id = p.PostID
    WHERE p.UserID != i.user_id;
END;

-- 2. 留言通知觸發器
CREATE TRIGGER TR_Comments_AddNotification
ON Comments
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO Notifications
        (recipient_id, sender_id, post_id, comment_id, type, content, is_read, created_at)
    SELECT 
        p.UserID,
        i.UserID,
        p.PostID,
        i.CommentID,
        'comment_post',
        (SELECT username FROM users WHERE id = i.UserID) + N' 在你的貼文發表了留言',
        0,
        GETDATE()
    FROM inserted i
    INNER JOIN Posts p ON i.PostID = p.PostID
    WHERE p.UserID != i.UserID;
END;

-- 3. 用戶檔案更新時間觸發器
CREATE TRIGGER TR_UserProfiles_UpdateTimestamp
ON user_profiles
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE user_profiles
    SET updated_at = GETDATE()
    FROM user_profiles up
    INNER JOIN inserted i ON up.id = i.id;
END;