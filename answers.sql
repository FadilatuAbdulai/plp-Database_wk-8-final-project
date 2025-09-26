DROP DATABASE IF EXISTS ecommerce_store;
CREATE DATABASE ecommerce_store
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
USE ecommerce_store;

CREATE TABLE customers (
  customer_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_name NVARCHAR(150) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  phone VARCHAR(30),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE addresses (
  address_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NOT NULL,
  address_line1 VARCHAR(255) NOT NULL,
  address_line2 VARCHAR(255),
  city VARCHAR(100) NOT NULL,
  state VARCHAR(100),
  postal_code VARCHAR(30),
  country VARCHAR(100) NOT NULL,
  is_default BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_addresses_customer ON addresses(customer_id);

CREATE TABLE categories (
  category_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE suppliers (
  supplier_id INT AUTO_INCREMENT PRIMARY KEY,
  supplier_name VARCHAR(150) NOT NULL,
  contact_email VARCHAR(255),
  phone VARCHAR(30),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE products (
  product_id INT AUTO_INCREMENT PRIMARY KEY,
  product_code VARCHAR(50) NOT NULL UNIQUE,
  product_name VARCHAR(200) NOT NULL,
  category_id INT,
  description TEXT,
  buy_price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  sale_price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  quantity_in_stock INT NOT NULL DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (category_id) REFERENCES categories(category_id)
    ON DELETE SET NULL
    ON UPDATE CASCADE
) ENGINE=InnoDB;
CREATE INDEX idx_products_category ON products(category_id);

CREATE TABLE product_suppliers (
  product_id INT NOT NULL,
  supplier_id INT NOT NULL,
  supplier_sku VARCHAR(100),
  lead_time_days INT DEFAULT 7,
  PRIMARY KEY (product_id, supplier_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB;


CREATE TABLE orders (
  order_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NOT NULL,
  billing_address_id INT,
  shipping_address_id INT,
  order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
  status ENUM('Pending','Processing','Shipped','Delivered','Cancelled','Returned') NOT NULL DEFAULT 'Pending',
  subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  shipping DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  tax DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  total DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  FOREIGN KEY (billing_address_id) REFERENCES addresses(address_id)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  FOREIGN KEY (shipping_address_id) REFERENCES addresses(address_id)
    ON DELETE SET NULL
    ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_date ON orders(order_date);

CREATE TABLE order_details (
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL CHECK (quantity > 0),
  price_each DECIMAL(10,2) NOT NULL,
  line_total DECIMAL(12,2) AS (quantity * price_each) STORED,
  PRIMARY KEY (order_id, product_id),
  FOREIGN KEY (order_id) REFERENCES orders(order_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(product_id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_orderdetails_product ON order_details(product_id);


CREATE TABLE payments (
  payment_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT,
  customer_id INT,
  payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
  amount DECIMAL(12,2) NOT NULL,
  payment_method ENUM('Credit Card','PayPal','Bank Transfer','Cash') NOT NULL,
  transaction_ref VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (order_id) REFERENCES orders(order_id)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
    ON DELETE SET NULL
    ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_payments_order ON payments(order_id);


CREATE TABLE inventory_movements (
  movement_id INT AUTO_INCREMENT PRIMARY KEY,
  product_id INT NOT NULL,
  change_qty INT NOT NULL,
  reason VARCHAR(100), -- 'Purchase','Sale','Return','Adjustment'
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (product_id) REFERENCES products(product_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB;


CREATE TABLE reviews (
  review_id INT AUTO_INCREMENT PRIMARY KEY,
  product_id INT NOT NULL,
  customer_id INT NULL,
  rating TINYINT NOT NULL CHECK (rating >= 1 AND rating <= 5),
  title VARCHAR(200),
  body TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (product_id) REFERENCES products(product_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
    ON DELETE SET NULL
    ON UPDATE CASCADE
) ENGINE=InnoDB;



CREATE TABLE users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(100) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('admin','manager','support') DEFAULT 'support',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;


CREATE VIEW vw_order_summary AS
SELECT
  o.order_id,
  o.order_date,
  o.customer_id,
  c.customer_name,
  o.status,
  o.total
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id;


INSERT INTO customers (customer_name, email, phone) VALUES
('John Doe', 'john@example.com', '0244000000'),
('Jane Smith', 'jane@example.com', '0244111111');

INSERT INTO categories (name, description) VALUES
('Electronics', 'Gadgets and devices'),
('Accessories', 'Device accessories');

INSERT INTO suppliers (supplier_name, contact_email) VALUES
('Acme Supplies', 'sales@acme.com');

INSERT INTO products (product_code, product_name, category_id, buy_price, sale_price, quantity_in_stock)
VALUES
('LAP-001','Laptop Model A', 1, 400.00, 599.00, 10),
('MOU-001','Wireless Mouse', 2, 5.00, 15.00, 100);
