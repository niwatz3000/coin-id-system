package com.coinid.imageingestion.service;

import com.google.api.core.ApiFuture;
import com.google.cloud.pubsub.v1.Publisher;
import com.google.protobuf.ByteString;
import com.google.pubsub.v1.PubsubMessage;
import com.google.pubsub.v1.TopicName;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import jakarta.annotation.PreDestroy;
import java.io.IOException;
import java.nio.charset.StandardCharsets;

@Service
public class EventPublisherService {

    private static final Logger log = LoggerFactory.getLogger(EventPublisherService.class);

    private final Publisher publisher;

    public EventPublisherService(
            @Value("${gcp.project-id}") String projectId,
            @Value("${gcp.pubsub.topic}") String topicId) throws IOException {
        TopicName topicName = TopicName.of(projectId, topicId);
        this.publisher = Publisher.newBuilder(topicName).build();
    }

    /**
     * Publishes a "coin image uploaded" event so the AI Coin Matching Service
     * can pick it up and run inference.
     */
    public void publishImageUploadedEvent(String matchingRequestId, String imageUrl) {
        String payload = """
                {"matchingRequestId":"%s","imageUrl":"%s"}
                """.formatted(matchingRequestId, imageUrl);

        PubsubMessage message = PubsubMessage.newBuilder()
                .setData(ByteString.copyFrom(payload, StandardCharsets.UTF_8))
                .putAttributes("eventType", "coin.image.uploaded")
                .build();

        ApiFuture<String> future = publisher.publish(message);
        try {
            String messageId = future.get();
            log.info("Published event {} for matching request {}", messageId, matchingRequestId);
        } catch (Exception e) {
            log.error("Failed to publish event for matching request {}", matchingRequestId, e);
            throw new RuntimeException("Failed to publish upload event", e);
        }
    }

    @PreDestroy
    public void shutdown() throws Exception {
        if (publisher != null) {
            publisher.shutdown();
        }
    }
}
