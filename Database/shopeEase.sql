CREATE DATABASE ShopEaseDB;
GO

USE ShopEaseDB;

CREATE TABLE Users (
    Id INT PRIMARY KEY IDENTITY,
    Name NVARCHAR(100),
    Email NVARCHAR(100) UNIQUE,
    Password NVARCHAR(200)
);

CREATE TABLE Products (
    Id INT PRIMARY KEY IDENTITY,
    Name NVARCHAR(100),
    Price DECIMAL(10,2),
    Image NVARCHAR(MAX)
);


DELETE FROM Wishlist
WHERE Id NOT IN (
    SELECT MIN(Id)
    FROM Wishlist
    GROUP BY UserId, ProductId
);


ALTER TABLE Products
ADD Description NVARCHAR(MAX)


CREATE TABLE Cart (
    Id INT PRIMARY KEY IDENTITY,
    UserId INT,
    ProductId INT,
    Quantity INT
);

CREATE TABLE Wishlist (
    Id INT PRIMARY KEY IDENTITY,
    UserId INT,
    ProductId INT
);



CREATE PROCEDURE sp_RegisterUser
    @Name NVARCHAR(100),
    @Email NVARCHAR(100),
    @Password NVARCHAR(200)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Users WHERE Email = @Email)
    BEGIN
        SELECT 'USER_EXISTS' AS Message
    END
    ELSE
    BEGIN
        INSERT INTO Users(Name, Email, Password)
        VALUES(@Name, @Email, @Password)

        SELECT 'SUCCESS' AS Message
    END
END




CREATE PROCEDURE sp_LoginUser
    @Email NVARCHAR(100),
    @Password NVARCHAR(200)
AS
BEGIN
    SELECT * FROM Users
    WHERE Email = @Email AND Password = @Password
END



CREATE PROCEDURE sp_GetProducts
AS
BEGIN
    SELECT * FROM Products
END




CREATE PROCEDURE sp_AddToCart
    @UserId INT,
    @ProductId INT,
    @Quantity INT
AS
BEGIN
    INSERT INTO Cart(UserId, ProductId, Quantity)
    VALUES(@UserId, @ProductId, @Quantity)
END



CREATE PROCEDURE sp_AddToWishlist
    @UserId INT,
    @ProductId INT
AS
BEGIN
    INSERT INTO Wishlist(UserId, ProductId)
    VALUES(@UserId, @ProductId)
END



ALTER PROCEDURE sp_AddToWishlist
    @UserId INT,
    @ProductId INT
AS
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM Wishlist 
        WHERE UserId = @UserId AND ProductId = @ProductId
    )
    BEGIN
        INSERT INTO Wishlist(UserId, ProductId)
        VALUES(@UserId, @ProductId)
    END
END


ALTER PROCEDURE sp_DeleteWishlist
    @UserId INT,
    @ProductId INT
AS
BEGIN
    DELETE FROM Wishlist 
    WHERE UserId = @UserId 
    AND ProductId = @ProductId
END



DROP TABLE Products;

INSERT INTO Products (Name, Price, Image, Description) VALUES
('Headphones', 59, 'https://plus.unsplash.com/premium_photo-1679513691474-73102089c117?w=500', 'High quality headphones'),

('Smart Watch', 129, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ4cCX-4nVCjJnBVzcLlLrYlg7XirOV_wc7dw&s', 'Smart watch with fitness tracking'),

('Purse', 59, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS5snZWUxUga9wbzQYzIPVNbS8GHGxSsTmFiLCSxHKkPjWVppVYmXD1x_TcEu0btFwy5Rc&usqp=CAU', 'Stylish purse'),

('Jewellery', 19, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQAiQm8n6PdWIRjSPoDXaOXsEIoG1iNM2hrQQ&s', 'Beautiful jewellery'),

('Dresses', 60, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTUB31YZ32qsHvWGaqjkHk_4b2Z0Z7HKgpDfw&s', 'Trendy dresses'),

('Girls Wear', 40, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR0-pF6dezRyCFm4DsBvnBn1EMHQFS_mn0Wqw&s', 'Girls wear'),

('Mens Wear', 53, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTOBfrOOLz00CuznGnL5g9iZ7SKqw5b-goG5Q&s', 'Mens fashion'),

('Boys Wear', 45, 'https://img.freepik.com/free-photo/low-angle-little-boy-posing_23-2148445671.jpg', 'Boys wear'),

('Foot Wear', 40, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQslxoe7E6YKFb7iftBQLMA2LyGr_Nb8VAnrA&s', 'Foot wear'),

('Shoes', 79, 'https://5.imimg.com/data5/SELLER/Default/2022/1/QZ/AO/RT/142262681/istockphoto-1301394040-170667a-500x500.jpg', 'Running shoes'),

('Bedsheets', 69, 'https://m.media-amazon.com/images/I/6189NPU1FNL._AC_UF894,1000_QL80_.jpg', 'Bedsheets'),

('Beauty Product', 89, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTWccYlAFa_NUSAXUM67H_byzm9ymsuXZlu7A&s', 'Beauty product');



ALTER PROCEDURE sp_GetProducts
AS
BEGIN
    SELECT Id, Name, Price, Image, Description
    FROM Products
END



SELECT * FROM Users;


CREATE PROCEDURE sp_GetCart
    @UserId INT
AS
BEGIN
    SELECT c.Id, c.ProductId, c.Quantity,
           p.Name, p.Price, p.Image
    FROM Cart c
    JOIN Products p ON c.ProductId = p.Id
    WHERE c.UserId = @UserId
END

CREATE PROCEDURE sp_UpdateCartQty
    @CartId INT,
    @Quantity INT
AS
BEGIN
    IF @Quantity <= 0
    BEGIN
        DELETE FROM Cart WHERE Id = @CartId
    END
    ELSE
    BEGIN
        UPDATE Cart SET Quantity = @Quantity WHERE Id = @CartId
    END
END



CREATE PROCEDURE sp_DeleteCartItem
    @CartId INT
AS
BEGIN
    DELETE FROM Cart WHERE Id = @CartId
END


SELECT * FROM Cart;



CREATE PROCEDURE sp_AddToCart
    @UserId INT,
    @ProductId INT,
    @Quantity INT
AS
BEGIN
    INSERT INTO Cart (UserId, ProductId, Quantity)
    VALUES (@UserId, @ProductId, @Quantity)
END


CREATE PROCEDURE sp_CheckCartItem
    @UserId INT,
    @ProductId INT
AS
BEGIN
    SELECT Id, Quantity 
    FROM Cart
    WHERE UserId = @UserId AND ProductId = @ProductId
END


SELECT * FROM Wishlist;

CREATE PROCEDURE sp_GetWishlist
    @UserId INT
AS
BEGIN
    SELECT w.Id, w.ProductId,
           p.Name, p.Price, p.Image
    FROM Wishlist w
    JOIN Products p ON w.ProductId = p.Id
    WHERE w.UserId = @UserId
END



CREATE PROCEDURE sp_DeleteWishlist
    @UserId INT,
    @ProductId INT
AS
BEGIN
    DELETE FROM Wishlist 
    WHERE UserId = @UserId AND ProductId = @ProductId
END




CREATE TABLE Categories (
    Id INT PRIMARY KEY IDENTITY,
    Name NVARCHAR(100),
    Image NVARCHAR(MAX)
);



CREATE TABLE Pro (
    Id INT PRIMARY KEY IDENTITY,
    Name NVARCHAR(200),
    Price DECIMAL(10,2),
    ImageUrl NVARCHAR(MAX),
    Description NVARCHAR(MAX),
    CategoryId INT,
    FOREIGN KEY (CategoryId) REFERENCES Categories(Id)
);



INSERT INTO Categories (Name, Image) VALUES
('Mobiles','https://img.freepik.com/premium-photo/row-smartphones-display-store-showcasing-various-colors-designs_14117-745595.jpg'),

('Women','https://img.freepik.com/free-photo/woman-pink-jacket-looking-camera_23-2148316471.jpg?semt=ais_incoming&w=740&q=80'),

('Men','https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT87M04zA2dx2J8VZqXlXajQ5LhsXCn_e_KQQ&s'),

('Electronics','https://t4.ftcdn.net/jpg/03/64/41/07/360_F_364410756_Ev3WoDfNyxO9c9n4tYIsU5YBQWAP3UF8.jpg'),

('Fashion','https://img.freepik.com/free-photo/woman-shopping-clothes-store_23-2148817136.jpg'),

('Kids','https://img.freepik.com/free-photo/little-boy-posing-studio_23-2148445671.jpg'),

('Grocery','https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSvrkqjdLrFUoY8LWznWqLy2vHIPdBfmgAvuA&s'),

('Books','https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRbvAjuhRJUomZiT3NL4gW_vdPmKr1KE7bzmA&s'),

('Beauty','https://img.freepik.com/free-photo/makeup-products-arrangement-top-view_23-2149096665.jpg'),

('Food','https://media.istockphoto.com/id/1457433817/photo/group-of-healthy-food-for-flexitarian-diet.jpg?b=1&s=612x612&w=0&k=20&c=V8oaDpP3mx6rUpRfrt2L9mZCD0_ySlnI7cd4nkgGAb8='),

('Flight Booking','https://www.shutterstock.com/image-vector/airline-tickets-web-banner-plane-260nw-1850211745.jpg');



INSERT INTO Pro (Name, Price, ImageUrl, Description, CategoryId) VALUES
('Samsung Galaxy S21',40099,'https://m.media-amazon.com/images/I/71xb2xkN5qL.jpg','6GB RAM | 128GB',1),
('iPhone 14',80099,'https://m.media-amazon.com/images/I/61VuVU94RnL.jpg','128GB Storage',1),
('OnePlus Nord CE',13099,'https://m.media-amazon.com/images/I/81fxjeu8fdL.jpg','8GB RAM | 128GB',1),
('Redmi Note 12',12099,'https://m.media-amazon.com/images/I/61HHS0HrjpL.jpg','6GB RAM | 128GB',1),
('Realme Narzo 60',11279,'https://m.media-amazon.com/images/I/71AvQd3VzqL.jpg','8GB RAM | 128GB',1),
('Vivo Y20',19999,'https://m.media-amazon.com/images/I/61bK6PMOC3L.jpg','4GB RAM | 64GB',1),
('Oppo A78',13349,'https://m.media-amazon.com/images/I/71yTvU9VgdL.jpg','8GB RAM | 256GB',1),
('Google Pixel 7',50099,'https://m.media-amazon.com/images/I/71pKVhll1IL.jpg','8GB RAM | 128GB',1);


INSERT INTO Pro (Name, Price, ImageUrl, Description, CategoryId) VALUES
('Men T-Shirt',499,'https://i.pinimg.com/736x/a9/76/06/a9760668a7a7ef982f2bc00e22593f72.jpg','Comfortable cotton t-shirt',2),
('Men Shirt',699,'https://i.pinimg.com/236x/47/ea/36/47ea3665abbca1de59d7574849a000f0.jpg','Formal wear shirt',2),
('Men Jeans',999,'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ4cCX-4nVCjJnBVzcLlLrYlg7XirOV_wc7dw&s','Slim fit jeans',2);



INSERT INTO Pro (Name, Price, ImageUrl, Description, CategoryId) VALUES
('Women Dress',899,'https://img.freepik.com/free-photo/woman-pink-jacket-looking-camera_23-2148316471.jpg','Stylish dress',3),
('Handbag',599,'https://i.pinimg.com/236x/47/ea/36/47ea3665abbca1de59d7574849a000f0.jpg','Premium handbag',3);



INSERT INTO Pro (Name, Price, ImageUrl, Description, CategoryId) VALUES
('Smart Watch',129,'https://t4.ftcdn.net/jpg/06/60/68/37/360_F_660683718_qo0q1V2RuLO56S7cu4VMb078m10U6WW8.jpg','Fitness tracking watch',4);




INSERT INTO Pro (Name, Price, ImageUrl, Description, CategoryId) VALUES
('Trendy Dress',799,'https://i.pinimg.com/736x/a9/76/06/a9760668a7a7ef982f2bc00e22593f72.jpg','Modern fashion wear',5);


INSERT INTO Pro (Name, Price, ImageUrl, Description, CategoryId) VALUES
('Kids Wear',499,'https://img.freepik.com/free-photo/little-boy-posing-studio_23-2148445671.jpg','Comfortable kids clothes',6);

INSERT INTO Pro (Name, Price, ImageUrl, Description, CategoryId) VALUES
('Vegetables Pack',299,'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSvrkqjdLrFUoY8LWznWqLy2vHIPdBfmgAvuA&s','Fresh vegetables',7);


INSERT INTO Pro(Name, Price, ImageUrl, Description, CategoryId) VALUES
('Motivation Book',199,'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRbvAjuhRJUomZiT3NL4gW_vdPmKr1KE7bzmA&s','Self improvement book',8);


INSERT INTO Pro (Name, Price, ImageUrl, Description, CategoryId) VALUES
('Makeup Kit',999,'https://img.freepik.com/free-photo/makeup-products-arrangement-top-view_23-2149096665.jpg','Complete beauty kit',9);


INSERT INTO Pro (Name, Price, ImageUrl, Description, CategoryId) VALUES
('Healthy Food Pack',399,'https://media.istockphoto.com/id/1457433817/photo/group-of-healthy-food-for-flexitarian-diet.jpg','Nutritious food items',10);


INSERT INTO Pro (Name, Price, ImageUrl, Description, CategoryId) VALUES
('Flight Ticket',4999,'https://www.shutterstock.com/image-vector/airline-tickets-web-banner-plane-260nw-1850211745.jpg','Book flight tickets',11);





CREATE PROCEDURE GetProductsByCategory
    @CategoryId INT
AS
BEGIN
    SELECT 
        Id,
        Name,
        Price,
        ImageUrl AS Image,
        Description,
        CategoryId
    FROM Pro
    WHERE CategoryId = @CategoryId
END


select * from Pro;



ALTER PROCEDURE sp_AddToCart
    @UserId INT,
    @ProductId INT,
    @Quantity INT
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM Cart 
        WHERE UserId = @UserId AND ProductId = @ProductId
    )
    BEGIN
        UPDATE Cart
        SET Quantity = Quantity + @Quantity
        WHERE UserId = @UserId AND ProductId = @ProductId
    END
    ELSE
    BEGIN
        INSERT INTO Cart(UserId, ProductId, Quantity)
        VALUES(@UserId, @ProductId, @Quantity)
    END
END







ALTER PROCEDURE sp_GetCart
    @UserId INT
AS
BEGIN
    SELECT c.Id, c.ProductId, c.Quantity,
           p.Name, p.Price, p.ImageUrl AS Image
    FROM Cart c
    JOIN Pro p ON c.ProductId = p.Id  
    WHERE c.UserId = @UserId
END




ALTER PROCEDURE sp_GetWishlist
    @UserId INT
AS
BEGIN
    SELECT w.Id, w.ProductId,
           p.Name, p.Price, p.ImageUrl AS Image
    FROM Wishlist w
    JOIN Pro p ON w.ProductId = p.Id   
    WHERE w.UserId = @UserId
END




ALTER PROCEDURE sp_GetCart
    @UserId INT
AS
BEGIN
    SELECT c.Id, c.ProductId, c.Quantity,
           p.Name, p.Price, p.ImageUrl AS Image
    FROM Cart c
    JOIN Pro p ON c.ProductId = p.Id   
    WHERE c.UserId = @UserId
END



ALTER PROCEDURE sp_GetWishlist
    @UserId INT
AS
BEGIN
    SELECT w.Id, w.ProductId,
           p.Name, p.Price, p.ImageUrl AS Image
    FROM Wishlist w
    JOIN Pro p ON w.ProductId = p.Id
    WHERE w.UserId = @UserId
END



ALTER TABLE Cart ADD ProductType NVARCHAR(20);
ALTER TABLE Wishlist ADD ProductType NVARCHAR(20);




ALTER PROCEDURE sp_AddToCart
    @UserId INT,
    @ProductId INT,
    @Quantity INT,
    @ProductType NVARCHAR(20)
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM Cart 
        WHERE UserId = @UserId AND ProductId = @ProductId AND ProductType = @ProductType
    )
    BEGIN
        UPDATE Cart
        SET Quantity = Quantity + @Quantity
        WHERE UserId = @UserId AND ProductId = @ProductId AND ProductType = @ProductType
    END
    ELSE
    BEGIN
        INSERT INTO Cart(UserId, ProductId, Quantity, ProductType)
        VALUES(@UserId, @ProductId, @Quantity, @ProductType)
    END
END





ALTER PROCEDURE sp_GetCart
    @UserId INT
AS
BEGIN
    SELECT 
        c.Id,
        c.ProductId,
        c.Quantity,
        c.ProductType,

        CASE 
            WHEN c.ProductType = 'PRO' THEN p.Name
            ELSE pr.Name
        END AS Name,

        CASE 
            WHEN c.ProductType = 'PRO' THEN p.Price
            ELSE pr.Price
        END AS Price,

        CASE 
            WHEN c.ProductType = 'PRO' THEN p.ImageUrl
            ELSE pr.Image
        END AS Image

    FROM Cart c
    LEFT JOIN Pro p ON c.ProductId = p.Id AND c.ProductType = 'PRO'
    LEFT JOIN Products pr ON c.ProductId = pr.Id AND c.ProductType = 'PRODUCT'
    WHERE c.UserId = @UserId
END



DELETE FROM Pro WHERE CategoryId=4;

INSERT INTO Pro (Name, Price, ImageUrl, Description, CategoryId) VALUES

-- Electronics (CategoryId = 4)
('Headphones', 999, 'https://plus.unsplash.com/premium_photo-1679513691474-73102089c117?w=500', 'High quality headphones', 4);


-- Women (CategoryId = 3)
('Purse', 59, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS5snZWUxUga9wbzQYzIPVNbS8GHGxSsTmFiLCSxHKkPjWVppVYmXD1x_TcEu0btFwy5Rc&usqp=CAU', 'Stylish purse', 3),
('Jewellery', 19, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQAiQm8n6PdWIRjSPoDXaOXsEIoG1iNM2hrQQ&s', 'Beautiful jewellery', 3),
('Dresses', 60, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTUB31YZ32qsHvWGaqjkHk_4b2Z0Z7HKgpDfw&s', 'Trendy dresses', 3),

-- Kids (CategoryId = 6)
('Girls Wear', 40, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR0-pF6dezRyCFm4DsBvnBn1EMHQFS_mn0Wqw&s', 'Girls wear', 6),
('Boys Wear', 45, 'https://img.freepik.com/free-photo/low-angle-little-boy-posing_23-2148445671.jpg', 'Boys wear', 6),

-- Men (CategoryId = 2)
('Mens Wear', 53, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTOBfrOOLz00CuznGnL5g9iZ7SKqw5b-goG5Q&s', 'Mens fashion', 2),

-- Fashion (CategoryId = 5)
('Foot Wear', 40, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQslxoe7E6YKFb7iftBQLMA2LyGr_Nb8VAnrA&s', 'Foot wear', 5),
('Shoes', 79, 'https://5.imimg.com/data5/SELLER/Default/2022/1/QZ/AO/RT/142262681/istockphoto-1301394040-170667a-500x500.jpg', 'Running shoes', 5),

-- Home (CategoryId = 5 or 7)
('Bedsheets', 69, 'https://m.media-amazon.com/images/I/6189NPU1FNL._AC_UF894,1000_QL80_.jpg', 'Bedsheets', 5),

-- Beauty (CategoryId = 9)
('Beauty Product', 89, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTWccYlAFa_NUSAXUM67H_byzm9ymsuXZlu7A&s', 'Beauty product', 9);



ALTER PROCEDURE sp_GetCart
    @UserId INT
AS
BEGIN
    SELECT c.Id, c.ProductId, c.Quantity,
           p.Name, p.Price, p.ImageUrl AS Image
    FROM Cart c
    JOIN Pro p ON c.ProductId = p.Id
    WHERE c.UserId = @UserId
END


ALTER PROCEDURE sp_GetWishlist
    @UserId INT
AS
BEGIN
    SELECT w.Id, w.ProductId,
           p.Name, p.Price, p.ImageUrl AS Image
    FROM Wishlist w
    JOIN Pro p ON w.ProductId = p.Id
    WHERE w.UserId = @UserId
END



ALTER TABLE Cart 
ADD ProductType NVARCHAR(20) DEFAULT 'PRO';


select * from Cart;

SELECT * FROM Pro;

SELECT * FROM Categories;

DELETE FROM Pro WHERE CategoryId = 3;

INSERT INTO Pro (Name, Price, ImageUrl, Description, CategoryId) VALUES

('Casual Shirt', 329, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT7d-flyfNs2PMivup80G4zgd-MjzfXlpmlfA&s', 'Cotton Slim Fit', 3),

('Denim Jacket', 459, 'https://cdn.shopify.com/s/files/1/0105/8232/files/jonrmonroe_17.jpg?v=1742561990', 'Blue Denim', 3),

('Formal Pants', 539, 'https://espanshe.com/cdn/shop/files/0W2A2493.jpg?v=1740555387', 'Black Slim Fit', 3),

('Hoodie', 345, 'https://campussutra.com/cdn/shop/products/AWIN21_HHH_M_PLN_BLGR_F.webp?v=1661863853', 'Winter Wear', 3),

('T-Shirt', 319, 'https://campussutra.com/cdn/shop/files/CSMSSTS7244_1_777d49f7-1a6a-4ab7-9b3c-1f40b93ece42.jpg?v=1731146662', 'Printed Cotton', 3),

('Track Pants', 525, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcREUp2V1Sed2-89taksSjDZWt-oLUt7JOaqfA&s', 'Sports Wear', 3),

('Kurta', 635, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRARgXTSM6YQdi0pdOLyVbYszluDJaWvL2gYw&s', 'Ethnic Wear', 3),

('Blazer', 789, 'https://successmenswear.com/cdn/shop/files/A_62b6fde8-f601-4bab-9def-c6e1ce9b6131.jpg?v=1766045469', 'Party Wear', 3),

('Shorts', 422, 'https://imagescdn.pantaloons.com/img/app/product/1/1018836-13894415.jpg?auto=format&w=450', 'Casual Wear', 3),

('Jeans', 449, 'https://laiger.in/wp-content/uploads/2025/06/61sCJy0QSrL._SY679_.jpg', 'Blue Denim', 3);


INSERT INTO Pro (Name, Price, ImageUrl, Description, CategoryId) VALUES

('Polo T-Shirt', 535, 'https://cdn.shopify.com/s/files/1/0420/7073/7058/files/22552f23ac2ac6e1f75223dcc59817b5.webp?v=1722841501&quality=80', 'Cotton Polo | Regular Fit', 3),

('Checked Shirt', 340, 'https://www.bushirt.in/cdn/shop/files/0A0A4583.jpg?v=1683288179', 'Casual Checks | Slim Fit', 3),

('Leather Jacket', 1120, 'https://lh4.googleusercontent.com/proxy/PVHLzfEgiA987O27D3s6tOBlv8HNTZqSmUuIQmF79Wwj-Yzs9Hf2GcmCikMsMeYXZFKryd8Q1qPQsbu2ACm-BLB1JfbH8F4GEHs0knvOTcebEIWn61V38KTBfOp-dIGm5W2aKcaLGilVgxKbp-LHvdY', 'Winter Wear | Premium', 3),

('Sweatshirt', 650, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSxt0wH4CpKgKGDcfCOqxQJIgbBsg9lX4uCLQ&s', 'Warm Cotton | Stylish', 3),

('Cargo Pants', 455, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR4dCxchrktRSYvA66ABGaNGdhYST6KU5Accw&s', 'Multi Pocket | Trendy', 3);





DELETE FROM Pro WHERE CategoryId = 2;
INSERT INTO Pro (Name, Price, ImageUrl, Description, CategoryId) VALUES

('Women Kurti', 349, 'https://encrypted-tbn2.gstatic.com/shopping?q=tbn:ANd9GcR3B7ElCUXPfo9-t5bcS6o3g8hIzkhkgfPRLhOBQiYFPdRi7_CTxqc3lnB9RpJ1q2FpVzF-4_2rKfvAuq62zC6-g1AkSds9pQzzKL4KJP_oZtCK1KbYcrU5', 'Cotton | Size M', 2),

('Women Saree', 489, 'https://encrypted-tbn0.gstatic.com/shopping?q=tbn:ANd9GcRia_5pwgFyTVZ1NONoaqUj_Odfj1CYarCjBnuIHs3TWj8_JmMCQVDobXfDTU9ooxM8mA92ejTyzgJdCWHUFFEKPDlbBzw7B04pbxuB446VHJX9HH5WjO4wUg', 'Silk | Size Free', 2),

('Women Jeans', 539, 'https://encrypted-tbn1.gstatic.com/shopping?q=tbn:ANd9GcTBJbvHCYpY8USrvQA_EvxC5lID97V6YRm8PrRJzcjEKGGrXV2CNH7XSmDlVPK3rBArLOEVGOkNlo7rQNG7EjKJF0L4x-dc-7wsTC6qX6uE', 'Denim | Size M', 2),

('Women Top', 229, 'https://encrypted-tbn0.gstatic.com/shopping?q=tbn:ANd9GcQ90w8jbOZR3HmGGWJrDYjXWKgmB6s0iElK4C370FMcr6GH4SsKo4UY2byvy_5Y6RcWORXfUKkD3ALlPDuQTKuDGLMjk4hErF-0weBJEZXQRKPbstboEqNKwQ', 'Cotton | Size M', 2),

('Women Dress', 359, 'https://encrypted-tbn2.gstatic.com/shopping?q=tbn:ANd9GcTje5_8Yo6EB8SNdfviDgwGoB_FiBXS4Mv5KOP5R3q3y2jyLpt-2WTU-tOxSjUbQpmJxAnHVgskA0nJNCxgBNzV8LubZocTws_huf_Dws8X7wKT8jZAjuaV', 'Polyester | Size M', 2),

('Handbag', 669, 'https://encrypted-tbn1.gstatic.com/shopping?q=tbn:ANd9GcS_Pkt3X4VoW0_NUiBnpK8avTnES6-sbv1pw_s9Ena6lYSqRquP5wD_rwGEDCk_xiTM-5ey5BAZFr-KnVSQJCx01AGzo4RuMAFsFPaa_tqdq2_0ljv928YhmJal', 'Leather | 12x8 inches', 2),

('Women Shoes', 779, 'https://encrypted-tbn1.gstatic.com/shopping?q=tbn:ANd9GcSeevEwTtBoN7HUhPoOOna_mcTGujXOKQYi9ifSQLlwv1Yfa8iQGAPiB1oOVu5VIUnZnBqNcCJNK9YvBaV2bgcQrVqJypbpaWAWeKTLNdzd7AEc4LTB9wwGK3o', 'Leather | Size 7', 2),

('Jewellery Set', 299, 'https://encrypted-tbn2.gstatic.com/shopping?q=tbn:ANd9GcQYv1OSVmXJYoysHnYyTbeXKRpZmwMbvVmwXHM8DqeTyuCFksU6mZleS7czm5ELlN9TkiJNiXvzSyYCCNV-L_sU_06MgZ513ss24s86D0Rv_XvcYTKcKKbSMg', 'Necklace & Earrings Set', 2);

INSERT INTO Pro (Name, Price, ImageUrl, Description, CategoryId) VALUES

('Women Palazzo Pants', 135, 'https://letsdressup.in/cdn/shop/files/Black-Palazzo-Pants_1445x.jpg?v=1753097850', 'Rayon | Size M', 2),

('Women Skirt', 445, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQyyfJ3sKELHRMTmHnH-GsRBhkDadTVoUS1vg&s', 'Cotton | Size S-M', 2),

('Women Blazer', 685, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS8LK6bVRz9Le9_nv_rTYteoEf8pEwdUGkWXQ&s', 'Formal Wear | Size M', 2),

('Women Night Suit', 255, 'https://assets.myntassets.com/h_1440,q_75,w_1080/v1/assets/images/2024/SEPTEMBER/25/zx8fAUi3_ac8c290814344ae786b5804acb84ab7a.jpg', 'Cotton | Comfortable Fit', 2),

('Women Hoodie', 465, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS9zcMVpZb3qfFrq6ISyhOkaaz-B8BBimm-mw&s', 'Winter Wear | Size L', 2),

('Women Leggings', 425, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR_NPe8qJRp8BCxz9ptDUTvbKpyLz6lDsnPcA&s', 'Stretchable | Size Free', 2),

('Women Sandals', 360, 'https://5.imimg.com/data5/SELLER/Default/2023/1/HJ/LE/VF/5951553/ladies-slippers-500x500.jpg', 'Casual | Size 6-8', 2),

('Women Watch', 820, 'https://www.carlington.in/cdn/shop/files/Carlington_elite_analog_ladies_watch_CT_2014_rosegold.jpg?v=1696691332&width=2400', 'Analog | Stylish Design', 2),

('Women Sunglasses', 340, 'https://s3.ap-south-1.amazonaws.com/eyesdeal.blinklinksolutions.com/eyesdeal/SUNGLASSES/OPIUM%20SUNGLASSES/2051274_1.JPEG', 'UV Protection | Trendy', 2),

('Makeup Kit', 1150, 'https://marscosmetics.in/cdn/shop/products/AKA2927.jpg?v=1764573141&width=2000', 'Full Combo | All-in-one kit', 2);

DELETE FROM Pro WHERE CategoryId=4;
INSERT INTO Pro (Name, Price, ImageUrl, Description, CategoryId) VALUES

('Smartphone', 9999,
'https://encrypted-tbn2.gstatic.com/shopping?q=tbn:ANd9GcRYULjPW-a-xjUkolK8rzH7SQV944PHYohgVa11285zZeTsvAUMEn3N53_hSdIbdDvdakAOAiLU7120snnLFZa47p9b2Q5qicLMn_qJB0t5wiqhvdj6EHKL',
'Latest Android Phone',
4),

('Laptop', 5899,
'https://m.media-amazon.com/images/I/510uTHyDqGL.jpg',
'High Performance Laptop',
4),

('Tablet', 32099,
'https://encrypted-tbn2.gstatic.com/shopping?q=tbn:ANd9GcTCi0j4X5Flpuof6ikc42PLG_20oFcZ5pakdXdAr3wRBlZwlOGsC1fd2oR1FUlun3R7GDpWNkugn-K-dtXXZczh-ODLS6tilV_Ci7LQVeI-HEKgbV0kSBRtHXg',
'10-inch Touchscreen',
4),


('Headphones', 1129,
'https://encrypted-tbn0.gstatic.com/shopping?q=tbn:ANd9GcQFfbig6tlsfSUL7-fZUF3aJQsiUgl4huO26DKCcTlZWRRWQBWS7dqguSNUbdN5qJyNHwg4UcoAntWpU39Ty2d-8Rgh-KKvadSMejWQOgwuK1o9yuFYncWLaw4',
'Noise Cancelling',
4),

('Camera', 50099,
'https://encrypted-tbn1.gstatic.com/shopping?q=tbn:ANd9GcRJbKV_pNnQQRFmLvTMj5pJp_fIYMnBCalw_OBgkGA-uqmQfv_y9g4vseAAD95iEkqYEhWf1XMSuz3EZLiqvQGyNe-xDqnLa9EuShvAQtpgnBEeXQrA-nQ01Kc',
'DSLR 24MP',
4),

('Wireless Mouse', 149,
'https://encrypted-tbn2.gstatic.com/shopping?q=tbn:ANd9GcTGTzQldeaXEY8b3POxrhR810sUy3KMtCnQtxYKJMMVIrVlT-s9x_PfdcCRQbpzYcdq7iOGl4fecT0S_QnIrW4BDyxSLsVI52QBdo0i1vgd8RT_SjGcRAF6lyE',
'Ergonomic Design',
4),

('Bluetooth Speaker', 979,
'https://encrypted-tbn0.gstatic.com/shopping?q=tbn:ANd9GcT4ni66s2SnUm5KjJaGDvc7k8xB3B-G11GfcxYQ3619o0jsgrN9v6h7ZHzsOjEp32f9ch53j8i_X4Abf4vJaXEEWTP_8cGojbNiF4z729oXg7itJUsjjwRdeQ',
'Portable & Powerful Sound',
4);

INSERT INTO Pro (Name, Price, ImageUrl, Description, CategoryId) VALUES

('Gaming Keyboard', 589,
'https://m.media-amazon.com/images/I/71kr3WAj1FL._AC_UY327_FMwebp_QL65_.jpg',
'RGB Backlit | Mechanical Feel',
4),

('External Hard Drive', 1119,
'https://m.media-amazon.com/images/I/81QpkIctqPL._AC_UY327_FMwebp_QL65_.jpg',
'1TB Storage | USB 3.0',
4),

('Power Bank', 439,
'https://www.stuffcool.com/cdn/shop/files/Click_20B.jpg?v=1747457789&width=2048',
'10000mAh | Fast Charging',
4),

('LED Monitor', 10099,
'https://t4.ftcdn.net/jpg/15/48/85/87/360_F_1548858714_KFSmCPQH5szffRH3Yj0kbUhHLd0Q2ZCw.jpg',
'24-inch Full HD Display',
4),

('Webcam', 10059,
'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTjx2HCPdp675OYdZL7hV8Bk4ImHzXM9rHsAQ&s',
'HD 1080p | Built-in Mic',
4);



DELETE FROM Pro WHERE CategoryId = 5;
INSERT INTO Pro (Name, Price, ImageUrl, Description, CategoryId) VALUES

('Leather Jacket', 820,
'https://encrypted-tbn0.gstatic.com/shopping?q=tbn:ANd9GcQHJe3LL2s6Cm7CzgYL3o0FUJ5ikseyjdsekEkitig6ArlaaNzJg_CkRkNtLOfhyzbUvm65YKXpSdwGhNKmrcUXmuHAr5pH6N9wVY5DU_t7sVmYwo1qhzHS',
'Classic Black Jacket',
5),

('Denim Jeans', 460,
'https://encrypted-tbn1.gstatic.com/shopping?q=tbn:ANd9GcTe6IhQ8l-QsLotIUbC1ejH0RCKvE6_dJor-_dU6kQ9CX2BzKS5YD334iybDAYTHNyqKmWt5YgeR6vH3Q-3mx0535noxWKmEWMntfCxKlWJ26zP7aylAzYe',
'Slim Fit Blue Jeans',
5),

('Summer Dress', 375,
'https://encrypted-tbn2.gstatic.com/shopping?q=tbn:ANd9GcTxnYoop4ChDzKmI3dWWH3nv7ZicRQu-djsU1kxQp6qLR3WJwTFH9USd2BvDV_MZPAmvZODVDbBcEl7Uv49feFgxrnxF3LUo74SRk7dpz8',
'Floral Print Dress',
5),

('Formal Shirt', 345,
'https://encrypted-tbn2.gstatic.com/shopping?q=tbn:ANd9GcRJwB3M6FPPS5ApBe-YfAMlatL0MByJdaiddpXzaQMu0QSq379Fhy-ESnk9v8wK_Fmj_dlzuD9g7vO1HiRUAwL89Jnj84BoZ6n-pCfAKqxgnlTYsIZNXXDW',
'Men''s Office Shirt',
5),

('Handbag', 490,
'https://encrypted-tbn2.gstatic.com/shopping?q=tbn:ANd9GcTCMsOztLo4wUXXTX7xsdQQR9WmnzkFPrSZ6rJJd1Gb2xCK5dlbERS1Nmj2e1NN7cGSzlzv0jCc14FYJzqKFYqKZxqKxmG1vyiwqdkbXlvqESOezsjhSoCq',
'Stylish Leather Bag',
5),

('Sneakers', 565,
'https://encrypted-tbn3.gstatic.com/shopping?q=tbn:ANd9GcTYsZSJvXDvrJQHGfmjj5wjezh_RhoWC3RE0gxHVlZoFvuxUWgpjLipSqD1chPe-dDFtSv4N0kru8ifNGy9dJceRCTN4CXWnDZYU6834i3Sz8qtR_5C2m6VnIE',
'Casual Everyday Shoes',
5),

('Scarf', 130,
'https://encrypted-tbn1.gstatic.com/shopping?q=tbn:ANd9GcRXkztsDSp6d5h9tWsIC6QyDj_5zTsgcoCg-6FitSjs0z4HmFVuTumLWr2_3Fd3ErFhjEc3SVCPPvtau-iZd--rYQqn53OPSTSFuSKRvGI',
'Woolen Winter Scarf',
5),

('Sunglasses', 250,
'https://encrypted-tbn1.gstatic.com/shopping?q=tbn:ANd9GcRZiuZucRkx0boQiQiiruzDCijzRkon7E-NxbdsHYMyoA36hAta5PiJH1o1uANHxRXKBVUbxiPje-4S06QoKHgQxyGR0Nrtou0ZPWMrDIECuV22BS_JXB7Aa1g',
'UV Protection Glasses',
5);

INSERT INTO Pro (Name, Price, ImageUrl, Description, CategoryId) VALUES

('Casual Blazer', 905,
'https://m.media-amazon.com/images/I/81v+SYk1-CL._AC_UY1100_.jpg',
'Stylish Slim Fit | Party Wear',
5),

('Women Heels', 570,
'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQqv4FChAxegumcknM7RfzMTFY5POVmNUkDGg&s',
'High Heel Sandals | Elegant',
5),

('Men Formal Shoes', 1110,
'https://lh5.googleusercontent.com/proxy/oYPSYhvp4PEDFR_Ffp2IA_QCjbQqayO274cIFvm-mHeGWLkeFYXSsXdxvCUhS-aLKFpebxr6q3MigBYbD4gPT_eEg4FGvEcNYnUEQ8mgnCiEEZAWkAYB1szYYLXoCg',
'Leather Shoes | Office Wear',
5),

('Backpack', 355,
'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSUPacumXLokXhq9TDtuwZLOKIzVTmIFmeCUA&s',
'Water Resistant | Travel Bag',
5),

('Winter Sweater', 600,
'https://icelandicstore.is/cdn/shop/files/Rova_Light_Grey_Sweater_Knitting_Kit_Sisu_knitwear.jpg?v=1728005943',
'Warm Knitwear | Casual Look',
5);







DELETE FROM Pro WHERE CategoryId = 6;
INSERT INTO Pro (Name, Price, ImageUrl, Description, CategoryId) VALUES

-- Boys
('Boys T-Shirt', 250,
'https://encrypted-tbn0.gstatic.com/shopping?q=tbn:ANd9GcRu774jT84RLngEm-BLsJ7acobCOcTSqqWpgHYwDtWs70A95ewWxuAmIFDb1gloQjBG0pu-CtF2ycQpYqDvxzTD5ABqNBHsxNEbcqzKk0Xr8PAtQINtXaSJBA',
'Casual Cotton Tee',
6),

('Boys Shorts', 150,
'https://encrypted-tbn0.gstatic.com/shopping?q=tbn:ANd9GcSI_Pie-7QLh6JilLOpZswsdzYdqUxeKG4QzgJBp3wgsPCcl2GmijnNvly2i8au6IbrwQNofIAKx8AH0lJo5I8vWMpFPwOdocEvC6Ajl2sxn1JMxnUv8PuSn0I',
'Comfortable Summer Shorts',
6),

('Boys Jacket', 355,
'https://encrypted-tbn2.gstatic.com/shopping?q=tbn:ANd9GcQU6DEsN7M1UKMVdPbWc1eOyoX_F7-blQjtqgkkoE9AC_ZNmNYKM6rePDwLfz9ZEJPdpjsfHIsoOSZnA0U_JlzpQwDe9uOzKw',
'Winter Warm Jacket',
6),

('Boys Sneakers', 825,
'https://encrypted-tbn3.gstatic.com/shopping?q=tbn:ANd9GcT1-urV6EzN6Uh2nJbOzjO2a9ZCyEjniReC8ZReiX9jcJe9yLV5V3FZu95k2AEVXT7hHZHGQ_VZhmveL5c4Xo6d61tkJ3AOxYm8lMpglDu9AKbU_Z7dbU2o',
'Casual Running Shoes',
6),

-- Girls
('Girls Dress', 520,
'https://encrypted-tbn2.gstatic.com/shopping?q=tbn:ANd9GcTJqgD3p8DmNMKCvggDdzJFGtFs7v3TijWqlZuBMdTLT5b-xW5Br2mDTBVlZx_JTJ7qOjy9gvp-7c192TWlEKKcfe7tGqKgmjOcCYhU7vkNSk-AGWOsCXNfbrE',
'Floral Party Dress',
6),

('Girls Skirt', 180,
'https://encrypted-tbn2.gstatic.com/shopping?q=tbn:ANd9GcQBV_-sWeFr1MkbS1l6TJahVRqo-_AWw0rhSjS4H0Oqpt2E9dW2f0V6qTbiVg7baapQLlUq-OA8fc83tj4ce5upVMcXiY1b',
'Cute Cotton Skirt',
6),

('Girls T-Shirt', 200,
'https://encrypted-tbn1.gstatic.com/shopping?q=tbn:ANd9GcQFmXca1VPb1jQaglm8RQTj0sq-hej8bhTpg3sd8rVzR5kOTzeouuo4QmvZt0qi9LSxOjj1NWYkpShUeRcmHr_A8NLwGyMldH4GIG5_NWSOw2Jxh9QaFUPjng',
'Colorful Summer Tee',
6),

('Girls Sandals', 220,
'https://encrypted-tbn0.gstatic.com/shopping?q=tbn:ANd9GcQH_NOicfHZOmIB5VEkVRs6YQ59niTAAtEZbIlHPCoInrggKxThK-lPNVn2jY7JTfrR06bWDVB1G_fWnvMkmpA_QiUivi2JDU9BHqPzdy8vuWEz8c9A7FwR',
'Comfortable Summer Sandals',
6);


INSERT INTO Pro (Name, Price, ImageUrl, Description, CategoryId) VALUES

('Boys Hoodie', 228,
'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTtGdna8XicjBY-ycow3XH-5aakQAoeYczd3g&s',
'Warm Winter Hoodie',
6),

('Girls Jacket', 435,
'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSQHSBDb1FG7_M0PwJBWQvhlS638BFV5C-lwA&s',
'Stylish Winter Jacket',
6),

('Kids School Bag', 122,
'https://thelittlelookers.com/cdn/shop/files/72.webp?v=1686727412',
'Durable Backpack for School',
6),

('Kids Sports Shoes', 330,
'https://www.mumkins.in/cdn/shop/files/boys-shoes-accord-001-blue-1.jpg?v=1757335783&width=1080',
'Comfortable Running Shoes',
6),

('Kids Night Suit', 150,
'https://chottuchottifashions.com/cdn/shop/files/PastelMickey.KidsNightSuit.png?v=1771222255',
'Soft Cotton Sleepwear',
6);







DELETE FROM Pro WHERE CategoryId = 7;

INSERT INTO Pro (Name, Price, ImageUrl, Description, CategoryId) VALUES

('Fresh Apples', 100, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSAZEK4hTyuWM0mU_hhTZLHJsRJusEDHdxfSA&s', 'Crisp Red Apples', 7),

('Bananas', 50, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSkXHRyG1n7Ykf1av-jbvVnV3horGiPR-o0cw&s', 'Ripe Yellow Bananas', 7),

('Milk Pack',30, 'https://tiimg.tistatic.com/fp/1/007/445/100-pure-fresh-amul-homogenized-cow-milk-pack-size-500-ml-193.jpg', 'Fresh Cow Milk 1L', 7),

('Eggs', 50, 'https://cdn.dotpe.in/longtail/store-items/3606255/YenQfqvd.jpeg', 'Fresh Farm Eggs, 12 pcs', 7),

('Tomatoes', 70, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ83Fw9z_3YOPp6U1MXhei5uThSTsKR1BpAcw&s', 'Fresh Red Tomatoes', 7),

('Potatoes', 40, 'https://plus.unsplash.com/premium_photo-1675365779531-031dfdcdf947?fm=jpg&q=60&w=3000&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NXx8cG90YXRvfGVufDB8fDB8fHww', 'Fresh Brown Potatoes', 7),

('Rice Pack', 150, 'https://lh5.googleusercontent.com/proxy/ZGAHj6MpLEmjafDaBISMrU6jr9lVAPOdUbLhV7JKRuQEmFYM8cBJZ5ySlfJ_WsC7XGbCoBnsv4TJTXg6GzQ8vpRVPWt5uH12JniQHI4hpQY1kDSb998H-nhZndngPLeQnQe1cIOwC-Gq4GSGE3HhiIEw9QugW2L6sVqH9cobT7usXfT49AhGj23E8nCKGw8FRoDtJ1F-zuPVA6pK1-WZiyDgRx33vm9akTs', 'Premium Basmati 5kg', 7),

('Cooking Oil', 110, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQtLJtOtFnERhS0d4KVO6qCqFifmTSdO1Z4eg&s', 'Refined Sunflower Oil 1L', 7);

INSERT INTO Pro (Name, Price, ImageUrl, Description, CategoryId) VALUES

('Bread Pack', 35,
'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSwzsSSpr72JXobHJnJqYKXENrawelKTW3Raw&s',
'Soft White Bread',
7),

('Butter', 50,
'https://tiimg.tistatic.com/fp/1/007/768/1-kilogram-yellow-colour-100-pure-natural-ingredients-butter-with-20-fat-content-975.jpg',
'Creamy Salted Butter 500g',
7),

('Sugar', 200,
'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTUFkiWWKJJMO25jGi-dZeflUt-9f0mLU01Qw&s',
'Refined White Sugar 1kg',
7),

('Salt', 10,
'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSvTxZAEZo8pnOXabTZhBSM4FL5heLgSau7cw&s',
'Iodized Table Salt 1kg',
7),

('Tea Powder',160,
'https://www.rippletea.com/cdn/shop/files/FoP_500g.jpg?v=1722936247&width=1946',
'Premium Tea 500g',
7);



DELETE FROM Pro WHERE CategoryId = 8;

INSERT INTO Pro (Name, Price, ImageUrl, Description, CategoryId) VALUES

('The Great Gatsby', 120, 'https://upload.wikimedia.org/wikipedia/commons/7/7a/The_Great_Gatsby_Cover_1925_Retouched.jpg', 'F. Scott Fitzgerald', 8),

('1984', 100, 'https://m.media-amazon.com/images/I/71wANojhEKL._AC_UF1000,1000_QL80_.jpg', 'George Orwell', 8),

('To Kill a Mockingbird', 210, 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4f/To_Kill_a_Mockingbird_%28first_edition_cover%29.jpg/250px-To_Kill_a_Mockingbird_%28first_edition_cover%29.jpg', 'Harper Lee', 8),

('Pride and Prejudice', 390, 'https://m.media-amazon.com/images/I/712P0p5cXIL._AC_UF1000,1000_QL80_.jpg', 'Jane Austen', 8),

('Harry Potter', 340, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSgGpv1ctGy0hjdg5Htgfh7PDosTEN5kkDNrw&s', 'J.K. Rowling', 8),

('The Hobbit', 130, 'https://upload.wikimedia.org/wikipedia/en/a/a9/The_Hobbit_trilogy_dvd_cover.jpg', 'J.R.R. Tolkien', 8),

('The Catcher in the Rye', 100, 'https://english-e-reader.net/covers/The_Catcher_in_the_Rye-Jerome_David_Salinger.jpg', 'J.D. Salinger', 8),

('The Alchemist', 32, 'https://m.media-amazon.com/images/I/617lxveUjYL.jpg', 'Paulo Coelho', 8);

INSERT INTO Pro (Name, Price, ImageUrl, Description, CategoryId) VALUES

('Atomic Habits', 250,
'https://m.media-amazon.com/images/I/91bYsX41DVL._AC_UF1000,1000_QL80_.jpg',
'James Clear',
8),

('Rich Dad Poor Dad', 350,
'https://m.media-amazon.com/images/I/81bsw6fnUiL._AC_UF1000,1000_QL80_.jpg',
'Robert Kiyosaki',
8),

('Think and Grow Rich', 300,
'https://m.media-amazon.com/images/I/71UypkUjStL._AC_UF1000,1000_QL80_.jpg',
'Napoleon Hill',
8),

('The Power of Now', 260,
'https://m.media-amazon.com/images/I/71sBtM3Yi5L._AC_UF1000,1000_QL80_.jpg',
'Eckhart Tolle',
8),

('Ikigai', 200,
'https://m.media-amazon.com/images/I/81l3rZK4lnL._AC_UF1000,1000_QL80_.jpg',
'Hector Garcia & Francesc Miralles',
8);










DELETE FROM Pro WHERE CategoryId = 9;
INSERT INTO Pro (Name, Price, ImageUrl, Description, CategoryId) VALUES

('Lipstick', 150, 'https://lh5.googleusercontent.com/proxy/XO1fPsKk-H10bDHUiCUNXd3qVc_ucTBcKEMCpMfaoiHKFsRuquUIbhkoFDI3L5MAAUCMnD6LZbnIgwkgKc-pvgWDiJ_QSxm6SIMn5cJvGjBekGKTotooTQaGEuw2dvPvX455dyfzNe9E0fYi_EK0Z9LsgLC6DQC9', 'Matte Red Lipstick', 9),

('Foundation', 200, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSi4T60iSmcHSGfLnTKr8DQglIzKu01pKsNCg&s', 'Liquid Foundation 30ml', 9),

('Perfume', 350, 'https://m.media-amazon.com/images/I/81NBOy6jDtL._AC_UF1000,1000_QL80_.jpg', 'Floral Fragrance 50ml', 9),

('Face Cream', 180, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQC6erXI8pD0WcnnDUoD9JCJq1xqLWqAR5qdg&s', 'Moisturizing Day Cream', 9),

('Nail Polish', 80, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR5LZg50UXAAoelbVFpSA-b_nR-zt-lPRVxKA&s', 'Bright Pink Shade', 9),

('Shampoo', 120, 'https://m.media-amazon.com/images/I/81q+yWBHpJL._AC_UF1000,1000_QL80_.jpg', 'Herbal Hair Shampoo', 9),

('Body Lotion', 140, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR4YcTgtUyoud3PxFHDKgx3iPEDP7x0nvUz9A&s', 'Vanilla Scent 200ml', 9),

('Face Mask', 100, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTOVdjKg78zHYcrLfRjSfHFUGnlsVyCCSn1Mw&s', 'Clay Mask for Skin', 9);




INSERT INTO Pro (Name, Price, ImageUrl, Description, CategoryId) VALUES

('Face Wash', 110,
'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRDKAu0ycW2-06svHKvbg_IQlOMh9HXemctAw&s',
'Gentle Daily Cleanser',
9),

('Hair Serum', 160,
'https://www.quickpantry.in/cdn/shop/products/livon-hair-serum-quick-pantry.jpg?v=1710538606',
'Smooth & Shine Serum',
9),

('Compact Powder', 130,
'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQI3c0Nfp8ze1Nc_KL01T_t_HiOpncleqNKNQ&s',
'Matte Finish Compact',
9),

('Makeup Brush Set', 220,
'https://praush.com/cdn/shop/files/1_95691912-b1df-47b4-8b3d-8dd95234162c.jpg?v=1731141637',
'Professional 10pcs Brush Set',
9),

('Sunscreen', 170,
'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRv1b5inqBI3Dbm5xDcBY3UCmM7C2YO6-aGDA&s',
'SPF 50 Sun Protection',
9);




DELETE FROM Pro WHERE CategoryId = 10;
INSERT INTO Pro (Name, Description, Price, ImageUrl, CategoryId) VALUES
('Fresh Apples', 'Crisp Red Apples', 100, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSAZEK4hTyuWM0mU_hhTZLHJsRJusEDHdxfSA&s', 10),

('Bananas', 'Ripe Yellow Bananas', 50, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSkXHRyG1n7Ykf1av-jbvVnV3horGiPR-o0cw&s', 10),

('Milk Pack', 'Fresh Cow Milk 1L',30, 'https://tiimg.tistatic.com/fp/1/007/445/100-pure-fresh-amul-homogenized-cow-milk-pack-size-500-ml-193.jpg', 10),

('Eggs', 'Fresh Farm Eggs, 12 pcs', 50, 'https://cdn.dotpe.in/longtail/store-items/3606255/YenQfqvd.jpeg', 10),

('Tomatoes', 'Fresh Red Tomatoes', 70, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ83Fw9z_3YOPp6U1MXhei5uThSTsKR1BpAcw&s', 10),

('Potatoes', 'Fresh Brown Potatoes', 40, 'https://plus.unsplash.com/premium_photo-1675365779531-031dfdcdf947?fm=jpg&q=60&w=3000&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NXx8cG90YXRvfGVufDB8fDB8fHww', 10),

('Rice Pack', 'Premium Basmati 5kg', 150, 'https://lh5.googleusercontent.com/proxy/ZGAHj6MpLEmjafDaBISMrU6jr9lVAPOdUbLhV7JKRuQEmFYM8cBJZ5ySlfJ_WsC7XGbCoBnsv4TJTXg6GzQ8vpRVPWt5uH12JniQHI4hpQY1kDSb998H-nhZndngPLeQnQe1cIOwC-Gq4GSGE3HhiIEw9QugW2L6sVqH9cobT7usXfT49AhGj23E8nCKGw8FRoDtJ1F-zuPVA6pK1-WZiyDgRx33vm9akTs', 10),

('Cooking Oil', 'Refined Sunflower Oil 1L', 110, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQtLJtOtFnERhS0d4KVO6qCqFifmTSdO1Z4eg&s', 10);


INSERT INTO Pro (Name, Description, Price, ImageUrl, CategoryId) VALUES

('Bread Loaf', 'Soft Fresh Bread', 35,
'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQDoYzheOLL5ydcVyXJQ8MhipYRWOsA3j5E6g&s',
10),

('Butter Pack', 'Creamy Dairy Butter 500g', 10,
'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR3oL49SGhvPJjJVfU9srkMRI8vtsk4FmnPTw&s',
10),

('Cheese Slices', 'Processed Cheese 200g', 40,
'https://www.quickpantry.in/cdn/shop/files/IMG-1562.jpg?v=1753951320&width=1214',
10),

('Orange Juice', 'Fresh Orange Juice 1L', 30,
'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcScR1Cf2pkEtRHs9_Wln_sL8ukIoBOfL2dicQ&s',
10),

('Biscuits Pack', 'Crunchy Tea Biscuits', 20,
'https://tiimg.tistatic.com/fp/1/007/922/sweet-delicious-round-amul-with-50-grams-packet-pack-chocolate-cookies-biscuit--163.jpg',
10);


DELETE FROM Pro Where CategoryId = 10;

INSERT INTO Pro (Name, Description, Price, ImageUrl, CategoryId) VALUES

('NYC → London', 'American Airlines | 12 Feb 2026', 550, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQITnhATvvi72M4YleSyoYDK-n0fy-LNL4LMw&s', 11),

('Paris → Tokyo', 'Air France | 25 Mar 2026', 780, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSJAs9N0IC5fyuRYhoukDAQ-yLKMz3beW6aVg&s', 11),

('Dubai → NYC', 'Emirates | 05 Apr 2026', 900, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT3rs1nvaZAOlATkHZ3TOwBUUOU1Wt5bBK7sw&s', 11),

('London → Dubai', 'British Airways | 15 May 2026', 620, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQH2BXf_W2KsnrkYlb0Pf2EjA1JQr3IyH7dnw&s', 11),

('Tokyo → Sydney', 'Qantas | 20 Jun 2026', 650, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ71l6PlWmgy4ORNZTQUpX-kd8hZ54Qyi5LDQ&s', 11),

('Sydney → NYC', 'Qantas | 10 Jul 2026', 720, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRN6oVtiA2RNLA0nyTclYETjYCxw-GHr3ENDw&s', 11),

('London → Paris', 'Air France | 30 Jul 2026', 200, 'https://aviationsourcenews.com/wp-content/uploads/2024/12/Air_France_B787-9_F-HRBB_flying_near_London_Heathrow_Airport.jpg', 11),

('NYC → Paris', 'Delta Airlines | 15 Aug 2026', 500, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSD0N-xlvf942ytgH9ADdtnsi4uu5FFvN_4mg&s', 11);

DELETE FROM Pro WHERE CategoryId=1;
INSERT INTO Pro (Name, Price, ImageUrl, Description, CategoryId) VALUES
('iQOO Neo 7', 13349, 'https://m.media-amazon.com/images/I/61JS7lF2aqL.jpg', '8GB RAM | 128GB | Gaming Phone', 1),

('Samsung Galaxy A54', 14029, 'https://m.media-amazon.com/images/I/71xMba-NW-L.jpg', '8GB RAM | 128GB | AMOLED Display', 1),

('Motorola Edge 40', 24099, 'https://motorolain.vtexassets.com/arquivos/ids/158526-800-auto?width=800&height=auto&aspect=true', '8GB RAM | 256GB | Curved Display', 1),

('Nokia G42', 25559, 'https://images.ctfassets.net/wcfotm6rrl7u/2k0kORXEbfJNTwsb5FCARl/f5963cb53131b0ecc5be78fc4bced618/nokia-G42_5G-so_pink-back-int.png?h=1000&fm=png&fl=png8', '6GB RAM | 128GB | 5G Ready', 1),

('Infinix Zero 5G', 12299, 'https://cdn.beebom.com/mobile/infinix-zero-5g-2023-front-and-back-1.png', '8GB RAM | 128GB | Fast Charging', 1),

('Tecno Camon 20', 21179, 'https://www.triveniworld.com/cdn/shop/products/tecno-camon-20-4g-with-fhd-big-amoled-display-art-edition-256-gb-8-gb-ram-refurbished-triveni-world-1.jpg?v=1736282324', '8GB RAM | 128GB | Camera Focused', 1),

('Asus ROG Phone 6', 11799, 'https://dlcdnwebimgs.asus.com/gain/3E5B1DD0-CAC0-4B35-8E2E-2D4116E17939/w250/fwebp', '12GB RAM | 256GB | Gaming Beast', 1),

('Sony Xperia 5 IV', 18199, 'https://www.corning.com/microsites/csm/gorillaglass/Sony/CGG_sony-xperia-5-vi.jpg', '8GB RAM | 128GB | Compact Flagship', 1),

('Lava Agni 2', 13269, 'https://images.indianexpress.com/2023/06/lava-agni-2-review.jpg', '8GB RAM | 256GB | Made in India', 1),

('Honor X9a', 33339, 'https://www-file.honor.com/content/dam/honor/global/products/smartphone/honor-x9a/imgs/s14-product11.png', '8GB RAM | 128GB | Slim Design', 1);

DELETE FROM Pro WHERE CategoryId=1;








CREATE TABLE Orders (
    Id INT PRIMARY KEY IDENTITY,
    UserId INT,
    TotalAmount DECIMAL(10,2),
    OrderDate DATETIME DEFAULT GETDATE()
);

DELETE FROM OrderItems WHERE OrderId = 34;

CREATE TABLE OrderItems (
    Id INT PRIMARY KEY IDENTITY,
    OrderId INT,
    ProductId INT,
    Quantity INT,
    Price DECIMAL(10,2),
    FOREIGN KEY (OrderId) REFERENCES Orders(Id)
);



CREATE PROCEDURE sp_PlaceOrder
    @UserId INT,
    @ProductId INT,
    @Quantity INT
AS
BEGIN
    DECLARE @OrderId INT
    DECLARE @Price DECIMAL(10,2)

    -- Get product price
    SELECT @Price = Price FROM Pro WHERE Id = @ProductId

    -- Create Order
    INSERT INTO Orders(UserId, TotalAmount)
    VALUES(@UserId, @Price * @Quantity)

    SET @OrderId = SCOPE_IDENTITY()

    -- Insert Order Item
    INSERT INTO OrderItems(OrderId, ProductId, Quantity, Price)
    VALUES(@OrderId, @ProductId, @Quantity, @Price)
END





ALTER PROCEDURE sp_PlaceOrder
    @UserId INT,
    @ProductId INT,
    @Quantity INT
AS
BEGIN
    DECLARE @OrderId INT
    DECLARE @Price DECIMAL(10,2)

    
    SELECT @Price = Price FROM Pro WHERE Id = @ProductId

    
    IF @Price IS NULL
    BEGIN
        RAISERROR('Product not found', 16, 1)
        RETURN
    END

    
    INSERT INTO Orders(UserId, TotalAmount)
    VALUES(@UserId, @Price * @Quantity)

    SET @OrderId = SCOPE_IDENTITY()

   
    INSERT INTO OrderItems(OrderId, ProductId, Quantity, Price)
    VALUES(@OrderId, @ProductId, @Quantity, @Price)
END





ALTER PROCEDURE sp_GetOrders
    @UserId INT
AS
BEGIN
    SELECT 
        o.Id,
        o.OrderDate,
        o.TotalAmount,
        oi.ProductId,
        oi.Quantity,
        oi.Price,
        p.Name,
        p.ImageUrl
    FROM Orders o
    INNER JOIN OrderItems oi ON o.Id = oi.OrderId
    LEFT JOIN Pro p ON oi.ProductId = p.Id  
    WHERE o.UserId = @UserId
    ORDER BY o.Id DESC
END



SELECT * FROM Users;

DELETE FROM Orders WHERE  Id=4;


ALTER TABLE Users
ADD OtpCode NVARCHAR(10),
    OtpExpiry DATETIME;




CREATE PROCEDURE sp_GenerateOtp
    @Email NVARCHAR(100)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Users WHERE Email = @Email)
    BEGIN
        SELECT 'Email not registered' AS Message;
        RETURN;
    END

    DECLARE @Otp NVARCHAR(6) =
        CAST(ABS(CHECKSUM(NEWID())) % 900000 + 100000 AS NVARCHAR);

    UPDATE Users
    SET OtpCode = @Otp,
        OtpExpiry = DATEADD(MINUTE, 5, GETDATE())
    WHERE Email = @Email;

    SELECT @Otp AS Otp, 'OTP Generated' AS Message; -- ✅ IMPORTANT
END


EXEC sp_GenerateOtp 'admin@gmail.com';

CREATE PROCEDURE sp_VerifyOtp
    @Email NVARCHAR(100),
    @Otp NVARCHAR(10)
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM Users 
        WHERE Email = @Email 
        AND OtpCode = @Otp 
        AND OtpExpiry > GETDATE()
    )
    BEGIN
        SELECT 'Valid' AS Message;
    END
    ELSE
    BEGIN
        SELECT 'Invalid or Expired OTP' AS Message;
    END
END







CREATE PROCEDURE sp_ResetPassword
    @Email NVARCHAR(100),
    @Password NVARCHAR(100)
AS
BEGIN
    UPDATE Users
    SET Password = @Password,
        OtpCode = NULL,
        OtpExpiry = NULL
    WHERE Email = @Email;

    SELECT 'Password Updated' AS Message;
END



