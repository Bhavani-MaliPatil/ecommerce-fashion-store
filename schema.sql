-- Create Database
CREATE DATABASE IF NOT EXISTS fashion_store;
USE fashion_store;

-- Table: users
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    address_line VARCHAR(255),
    city VARCHAR(255),
    state VARCHAR(255),
    pincode VARCHAR(20)
);

-- Table: categories
CREATE TABLE IF NOT EXISTS categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

-- Table: products
CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    category_id INT,
    image_url VARCHAR(255),
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
);

-- Table: product_variants
CREATE TABLE IF NOT EXISTS product_variants (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    size VARCHAR(50) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- Table: cart
CREATE TABLE IF NOT EXISTS cart (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Table: cart_items
CREATE TABLE IF NOT EXISTS cart_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cart_id INT NOT NULL,
    product_id INT NOT NULL,
    variant_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    FOREIGN KEY (cart_id) REFERENCES cart(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (variant_id) REFERENCES product_variants(id) ON DELETE CASCADE
);

-- Table: orders
CREATE TABLE IF NOT EXISTS orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) NOT NULL DEFAULT 'PLACED',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Table: order_items
CREATE TABLE IF NOT EXISTS order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    variant_id INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (variant_id) REFERENCES product_variants(id) ON DELETE CASCADE
);

-- Insert categories
INSERT INTO categories (id, name) VALUES 
(1, 'Men'),
(2, 'Women')
ON DUPLICATE KEY UPDATE name=VALUES(name);

-- Insert sample products with images matching assets
INSERT INTO products (id, name, description, price, category_id, image_url) VALUES
(1, 'Classic Black T-Shirt', 'A premium cotton crewneck t-shirt in classic black. Breathable, comfortable, and perfect for layering.', 599.00, 1, 'assets/images/black_tshirt.jpg'),
(2, 'Slim Fit Blue Jeans', 'Classic blue denim jeans with a modern slim fit. Made with lightweight stretch denim for all-day comfort.', 1299.00, 1, 'assets/images/blue_jeans.jpg'),
(3, 'Casual Blue Shirt', 'Button-down blue cotton shirt. Great for both business-casual and weekend styling.', 999.00, 1, 'assets/images/blue_shirt.jpg'),
(4, 'Green Hoodie', 'Cozy green pullover hoodie made from soft fleece. Features a spacious kangaroo pocket.', 1199.00, 1, 'assets/images/green_hoodie.jpg'),
(5, 'Grey Hoodie', 'Versatile grey pullover hoodie. Warm, soft, and highly durable for daily wear.', 1199.00, 1, 'assets/images/grey_hoodie.jpg'),
(6, 'Classic Denim Jacket', 'Timeless blue denim jacket. A rugged, stylish outer layer that gets better with age.', 1899.00, 1, 'assets/images/denim_jacket.jpg'),
(7, 'White Sneakers', 'Clean, minimalistic white leather sneakers. The ultimate footwear staple that matches any outfit.', 1499.00, 1, 'assets/images/white_sneakers.jpg'),
(8, 'Basic White T-Shirt', 'An essential white cotton t-shirt. Soft-washed for ultimate comfort and daily durability.', 499.00, 1, 'assets/images/white_tshirt.jpg'),
(9, 'Elegant Pink Dress', 'A beautiful and elegant pastel pink dress, perfect for garden parties or evening events.', 1799.00, 2, 'assets/images/pink_dress.jpg'),
(10, 'Vibrant Red Dress', 'A striking and bold red dress featuring an elegant modern cut and flowing silhouette.', 1999.00, 2, 'assets/images/red_dress.jpg'),
(11, 'Chic Black Skirt', 'A versatile high-waisted black skirt. A chic styling piece that pairs with everything.', 799.00, 2, 'assets/images/black_skirt.jpg'),
(12, 'Floral Print Top', 'Lightweight summer top featuring a beautiful and delicate floral print.', 699.00, 2, 'assets/images/floral_top.jpg'),
(13, 'Yellow Casual Top', 'Bright and cheerful yellow top. Soft fabric with a relaxed, modern fit.', 699.00, 2, 'assets/images/yellow_top.jpg')
ON DUPLICATE KEY UPDATE name=VALUES(name), description=VALUES(description), price=VALUES(price), category_id=VALUES(category_id), image_url=VALUES(image_url);

-- Insert product variants (sizes and stock)
INSERT INTO product_variants (product_id, size, stock) VALUES
(1, 'S', 20), (1, 'M', 35), (1, 'L', 40), (1, 'XL', 15),
(2, '30', 10), (2, '32', 15), (2, '34', 20), (2, '36', 10),
(3, 'M', 25), (3, 'L', 30), (3, 'XL', 20),
(4, 'S', 12), (4, 'M', 18), (4, 'L', 22), (4, 'XL', 10),
(5, 'S', 15), (5, 'M', 20), (5, 'L', 25), (5, 'XL', 12),
(6, 'M', 15), (6, 'L', 20), (6, 'XL', 15),
(7, '8', 12), (7, '9', 18), (7, '10', 15), (7, '11', 8),
(8, 'S', 30), (8, 'M', 45), (8, 'L', 50), (8, 'XL', 25),
(9, 'S', 10), (9, 'M', 15), (9, 'L', 12),
(10, 'S', 8), (10, 'M', 12), (10, 'L', 10),
(11, 'S', 15), (11, 'M', 20), (11, 'L', 15),
(12, 'S', 20), (12, 'M', 25), (12, 'L', 18),
(13, 'S', 15), (13, 'M', 22), (13, 'L', 20)
ON DUPLICATE KEY UPDATE stock=VALUES(stock);
