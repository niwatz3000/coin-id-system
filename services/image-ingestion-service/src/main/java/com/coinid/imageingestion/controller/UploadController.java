package com.coinid.imageingestion.controller;

import com.coinid.imageingestion.service.EventPublisherService;
import com.coinid.imageingestion.service.FileProcessingService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/upload")
public class UploadController {

    private final FileProcessingService fileProcessingService;
    private final EventPublisherService eventPublisherService;

    public UploadController(FileProcessingService fileProcessingService,
                             EventPublisherService eventPublisherService) {
        this.fileProcessingService = fileProcessingService;
        this.eventPublisherService = eventPublisherService;
    }

    @PostMapping
    public ResponseEntity<?> uploadCoinImage(@RequestParam("file") MultipartFile file,
                                              @RequestParam(value = "userId", required = false) String userId) {
        try {
            String imageUrl = fileProcessingService.storeImage(file);

            // matchingRequestId correlates the upload with the eventual AI match result
            String matchingRequestId = UUID.randomUUID().toString();

            // TODO: persist a MATCHING_REQUESTS row with status=PENDING via a shared DB module
            // or a call back to user-catalog-service before publishing the event.

            eventPublisherService.publishImageUploadedEvent(matchingRequestId, imageUrl);

            return ResponseEntity.accepted().body(Map.of(
                    "matchingRequestId", matchingRequestId,
                    "imageUrl", imageUrl,
                    "status", "PENDING"
            ));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (IOException e) {
            return ResponseEntity.internalServerError().body(Map.of("error", "Failed to store image"));
        }
    }
}
