Create DATABASE LibraryDB;
Use LibraryDB;

-- Create Tables

-- Creating Books Table
Create Table Books (
	book_id INT Primary key auto_increment,
    title Varchar(255) NOT null,
    author Varchar(255) NOT Null,
    genre Varchar(100),
    copies_available INT Default 1
);

-- Creating Members Table
Create Table Members (
	member_id int primary key auto_increment,
    name varchar(255) not null,
    email varchar(255) unique,
    phone varchar(15),
    join_date date default (current_date)
);

-- Create BorrowedBooks Table
Create table BorrowedBooks (
	borrow_id INT primary key auto_increment,
    member_id INT,
    book_id INT,
    borrow_date DATE default (Current_DATE),
    return_date DATE,
    status ENUM('Borrowed', 'Returned') default 'Borrowed',
    foreign key (member_id) References Members(member_id),
	FOREIGN KEY (book_id) REFERENCES Books(book_id)
);


-- Inserting Sample Data
INSERT INTO Books (title, author, genre, copies_available) VALUES
('The Alchemist', 'Paulo Coelho', 'Fiction', 5),
('Rich Dad Poor Dad', 'Robert Kiyosaki', 'Finance', 3),
('Harry Potter', 'J.K. Rowling', 'Fantasy', 2);

-- Inserting Members
INSERT INTO Members (name, email, phone) VALUES
('Anurag Deshmukh', 'anurag@gmail.com', '8123432354'),
('Bob ', 'bob@gmail.com', '9876543210');

-- Insert Borrowed Books
INSERT INTO BorrowedBooks (member_id, book_id, return_date) VALUES
(1, 1, '2025-03-01'),
(2, 3, '2025-03-05');


-- Query the Data 

-- listing all available books
Select * FROM Books where copies_available >0;

-- Checking borrowed books by members

SELECT m.name, b.title, bb.borrow_date, bb.return_date
FROM BorrowedBooks bb
JOIN Members m ON bb.member_id = m.member_id
JOIN Books b ON bb.book_id = b.book_id
WHERE bb.status = 'Borrowed';


-- Creating Stored Procedures
-- Procedure to Borrow a Book

DELIMITER //
CREATE PROCEDURE BorrowBook(IN memberId INT, IN bookId INT)
BEGIN
    DECLARE copies INT;
    
    -- Check if the book is available
    SELECT copies_available INTO copies FROM Books WHERE book_id = bookId;

    IF copies > 0 THEN
        -- Insert into BorrowedBooks
        INSERT INTO BorrowedBooks (member_id, book_id, borrow_date, status)
        VALUES (memberId, bookId, CURDATE(), 'Borrowed');
        
        -- Update book stock
        UPDATE Books SET copies_available = copies - 1 WHERE book_id = bookId;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No copies available';
    END IF;
END //
DELIMITER ;


-- Procedure to Return a Book
DELIMITER //
CREATE PROCEDURE ReturnBook(IN borrowId INT)
BEGIN
    DECLARE bookId INT;
    
    -- Get book_id
    SELECT book_id INTO bookId FROM BorrowedBooks WHERE borrow_id = borrowId;
    
    -- Update BorrowedBooks table
    UPDATE BorrowedBooks SET return_date = CURDATE(), status = 'Returned' WHERE borrow_id = borrowId;
    
    -- Increase book stock
    UPDATE Books SET copies_available = copies_available + 1 WHERE book_id = bookId;
END //
DELIMITER ;


-- Implementing Triggers

-- Auto-update book copies when returned
DELIMITER $$

CREATE TRIGGER after_return_book
AFTER UPDATE ON BorrowedBooks
FOR EACH ROW
BEGIN
    IF NEW.status = 'Returned' THEN
        UPDATE Books 
        SET copies_available = copies_available + 1 
        WHERE book_id = NEW.book_id;
    END IF;
END $$

DELIMITER ;

-- Security & User Roles
-- Create a Library Staff User
CREATE USER 'librarian'@'localhost' IDENTIFIED BY 'password123';
GRANT SELECT, INSERT, UPDATE, DELETE ON LibraryDB.* TO 'librarian'@'localhost';
FLUSH PRIVILEGES;

-- Transactions for Safe Updates
-- Borrowing & Returning a Book Safely

START TRANSACTION;

CALL BorrowBook(1, 2); -- Borrow a book
CALL ReturnBook(1);     -- Return a book

COMMIT;

-- Create Views for Reporting
-- View to Show All Borrowed Books
CREATE VIEW BorrowedBooksView AS
SELECT bb.borrow_id, m.name AS Member, b.title AS Book, bb.borrow_date, bb.return_date, bb.status
FROM BorrowedBooks bb
JOIN Members m ON bb.member_id = m.member_id
JOIN Books b ON bb.book_id = b.book_id;

-- Using the view
Select * From BorrowedBooksView where status = 'Borrowed';

