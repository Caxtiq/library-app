package com.example.library_app.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.library_app.model.Book;

public interface BookRepository extends JpaRepository<Book, Long> {
}