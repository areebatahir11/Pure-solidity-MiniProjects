// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract LibraryManagement {
    address public admin;

    constructor() {
        admin = msg.sender;
    }

    struct Book {
        string title;
        string author;
        uint id;
        uint totalCopies;
    }

    Book[] public books;
    mapping(uint => Book) public bookById;
    mapping(address => mapping(uint => bool)) public hasBorrowed;

    event BookAdded(uint id, string title);
    event BookBorrowed(address indexed user, uint id);
    event BookReturned(address indexed user, uint id);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }

    function addBook(string memory _title, string memory _author, uint _id, uint _copies) public onlyAdmin {
        require(bookById[_id].id != _id, "ID exists");

        Book memory newBook = Book(_title, _author, _id, _copies);
        books.push(newBook);
        bookById[_id] = newBook;

        emit BookAdded(_id, _title);
    }

    function borrowBook(uint _id) public {
        Book storage b = bookById[_id];
        require(b.totalCopies > 0, "Not available");
        require(!hasBorrowed[msg.sender][_id], "Already borrowed");

        b.totalCopies -= 1;
        hasBorrowed[msg.sender][_id] = true;

        emit BookBorrowed(msg.sender, _id);
    }

    function returnBook(uint _id) public {
        require(hasBorrowed[msg.sender][_id], "You didn't borrow this");

        bookById[_id].totalCopies += 1;
        hasBorrowed[msg.sender][_id] = false;

        emit BookReturned(msg.sender, _id);
    }
}
