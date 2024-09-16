package com.example.library_app;

import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.context.annotation.Bean;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

import com.example.library_app.model.Book;
import com.example.library_app.repository.BookRepository;

@SpringBootApplication
@EntityScan("com.example.library_app.model")
@EnableJpaRepositories("com.example.library_app.repository")
public class LibraryAppApplication {

    public static void main(String[] args) {
        SpringApplication.run(LibraryAppApplication.class, args);
    }

    @Bean
    public CommandLineRunner demo(BookRepository repository) {
        return (args) -> {
            repository.save(new Book("To Kill a Mockingbird", "Harper Lee", "978-0446310789"));
            repository.save(new Book("1984", "George Orwell", "978-0451524935"));
            repository.save(new Book("The Great Gatsby", "F. Scott Fitzgerald", "978-0743273565"));
        };
    }
}