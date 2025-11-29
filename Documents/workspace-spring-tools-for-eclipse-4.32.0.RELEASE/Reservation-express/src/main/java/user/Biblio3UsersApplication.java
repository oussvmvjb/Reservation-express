package user;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@SpringBootApplication
@EntityScan(basePackages = {"model", "user.model"})
@EnableJpaRepositories(basePackages = {"repository", "user.repository"})
@ComponentScan(basePackages = {"controller", "service", "config", "user.controller", "user.service"})
public class Biblio3UsersApplication {

    public static void main(String[] args) {
        SpringApplication.run(Biblio3UsersApplication.class, args);
      
    }
}