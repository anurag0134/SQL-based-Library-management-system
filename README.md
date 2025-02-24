# 📚 SQL-Based Library Management System

## 🔹 Overview
A simple SQL-based **Library Management System** that helps manage books, members, and borrowing records efficiently. This project includes:

✅ **Database Schema** (Tables for Books, Members, and Borrowed Books)  
✅ **Stored Procedures** for borrowing and returning books  
✅ **Triggers** for automatic book stock updates  
✅ **User Roles & Security**  
✅ **Views & Reporting**  
✅ **Transactions for Safe Updates**  

---

## 📌 **1. Database Setup**

### **1.1 Create Database**
```sql
CREATE DATABASE LibraryDB;
USE LibraryDB;
```

---

## 📌 **2. Create Tables**

### **2.1 Books Table**
```sql
CREATE TABLE Books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255) NOT NULL,
    genre VARCHAR(100),
    copies_available INT DEFAULT 1
);
```

### **2.2 Members Table**
```sql
CREATE TABLE Members (
    member_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(15),
    join_date DATE DEFAULT CURRENT_DATE
);
```

### **2.3 Borrowed Books Table**
```sql
CREATE TABLE BorrowedBooks (
    borrow_id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT,
    book_id INT,
    borrow_date DATE DEFAULT CURRENT_DATE,
    return_date DATE,
    status ENUM('Borrowed', 'Returned') DEFAULT 'Borrowed',
    FOREIGN KEY (member_id) REFERENCES Members(member_id),
    FOREIGN KEY (book_id) REFERENCES Books(book_id)
);
```

---

## 📌 **3. Insert Sample Data**

### **3.1 Insert Books**
```sql
INSERT INTO Books (title, author, genre, copies_available) VALUES
('The Alchemist', 'Paulo Coelho', 'Fiction', 5),
('Rich Dad Poor Dad', 'Robert Kiyosaki', 'Finance', 3),
('Harry Potter', 'J.K. Rowling', 'Fantasy', 2);
```

### **3.2 Insert Members**
```sql
INSERT INTO Members (name, email, phone) VALUES
('Anurag Deshmukh', 'anurag@gmail.com', '8123432354'),
('Bob ', 'bob@gmail.com', '9876543210');
```

### **3.3 Insert Borrowed Books**
```sql
INSERT INTO BorrowedBooks (member_id, book_id, return_date) VALUES
(1, 1, '2025-03-01'),
(2, 3, '2025-03-05');
```

---

## 📌 **4. Query the Data**

### **4.1 List Available Books**
```sql
SELECT * FROM Books WHERE copies_available > 0;
```

### **4.2 Check Borrowed Books**
```sql
SELECT m.name, b.title, bb.borrow_date, bb.return_date
FROM BorrowedBooks bb
JOIN Members m ON bb.member_id = m.member_id
JOIN Books b ON bb.book_id = b.book_id
WHERE bb.status = 'Borrowed';
```

---

## 📌 **5. Stored Procedures**

### **5.1 Borrow a Book**
```sql
DELIMITER //
CREATE PROCEDURE BorrowBook(IN memberId INT, IN bookId INT)
BEGIN
    DECLARE copies INT;
    SELECT copies_available INTO copies FROM Books WHERE book_id = bookId;
    IF copies > 0 THEN
        INSERT INTO BorrowedBooks (member_id, book_id, borrow_date, status)
        VALUES (memberId, bookId, CURDATE(), 'Borrowed');
        UPDATE Books SET copies_available = copies - 1 WHERE book_id = bookId;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No copies available';
    END IF;
END //
DELIMITER ;
```

### **5.2 Return a Book**
```sql
DELIMITER //
CREATE PROCEDURE ReturnBook(IN borrowId INT)
BEGIN
    DECLARE bookId INT;
    SELECT book_id INTO bookId FROM BorrowedBooks WHERE borrow_id = borrowId;
    UPDATE BorrowedBooks SET return_date = CURDATE(), status = 'Returned' WHERE borrow_id = borrowId;
    UPDATE Books SET copies_available = copies_available + 1 WHERE book_id = bookId;
END //
DELIMITER ;
```

---

## 📌 **6. Triggers**

### **6.1 Auto-Update Book Stock When Returned**
```sql
CREATE TRIGGER after_return_book
AFTER UPDATE ON BorrowedBooks
FOR EACH ROW
BEGIN
    IF NEW.status = 'Returned' THEN
        UPDATE Books SET copies_available = copies_available + 1 WHERE book_id = NEW.book_id;
    END IF;
END;
```

---

## 📌 **7. Security & User Roles**

### **7.1 Create a Library Staff User**
```sql
CREATE USER 'librarian'@'localhost' IDENTIFIED BY 'password123';
GRANT SELECT, INSERT, UPDATE, DELETE ON LibraryDB.* TO 'librarian'@'localhost';
FLUSH PRIVILEGES;
```

---

## 📌 **8. Transactions for Safe Updates**

### **8.1 Borrowing & Returning a Book Safely**
```sql
START TRANSACTION;
CALL BorrowBook(1, 2); -- Borrow a book
CALL ReturnBook(1);     -- Return a book
COMMIT;
```

---

## 📌 **9. Views for Reporting**

### **9.1 View for Borrowed Books**
```sql
CREATE VIEW BorrowedBooksView AS
SELECT bb.borrow_id, m.name AS Member, b.title AS Book, bb.borrow_date, bb.return_date, bb.status
FROM BorrowedBooks bb
JOIN Members m ON bb.member_id = m.member_id
JOIN Books b ON bb.book_id = b.book_id;
```

### **9.2 Use the View**
```sql
SELECT * FROM BorrowedBooksView WHERE status = 'Borrowed';
```

---

## 🎯 **Final Outcome**
✔ **Functional Library System**  
✔ **Procedures for Borrowing & Returning Books**  
✔ **Triggers for Auto-updating Stock**  
✔ **User Roles for Security**  
✔ **Transactions for Safe Operations**  
✔ **Views for Reporting**  

 
