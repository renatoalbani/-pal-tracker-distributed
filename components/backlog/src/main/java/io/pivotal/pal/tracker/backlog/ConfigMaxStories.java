package io.pivotal.pal.tracker.backlog;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

@Configuration
public class ConfigMaxStories {

    private final Integer maxStories;

    public ConfigMaxStories(@Value("${backlog.stories.max}") Integer maxStories) {
        this.maxStories = maxStories;
    }

    public Integer getMaxStories() {
        return maxStories;
    }

}
