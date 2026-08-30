import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

export interface AuthResponse {
  token: string;
  email: string;
  role: string;
}

export interface UploadResponse {
  matchingRequestId: string;
  imageUrl: string;
  status: string;
}

export interface MatchingRequest {
  id: string;
  status: 'PENDING' | 'PROCESSING' | 'MATCHED' | 'FAILED';
  matchedCoinId?: string;
  confidenceScore?: number;
  errorMessage?: string;
}

@Injectable({ providedIn: 'root' })
export class ApiService {
  // Base URLs — in production these should route through the
  // Google Cloud Load Balancer / API Gateway path prefixes.
  private readonly userCatalogBaseUrl = 'http://localhost:8081/api';
  private readonly imageIngestionBaseUrl = 'http://localhost:8082/api';

  constructor(private http: HttpClient) {}

  login(email: string, password: string): Observable<AuthResponse> {
    return this.http.post<AuthResponse>(`${this.userCatalogBaseUrl}/auth/login`, { email, password });
  }

  register(email: string, password: string, displayName: string): Observable<AuthResponse> {
    return this.http.post<AuthResponse>(`${this.userCatalogBaseUrl}/auth/register`, { email, password, displayName });
  }

  uploadCoinImage(file: File, userId?: string): Observable<UploadResponse> {
    const formData = new FormData();
    formData.append('file', file);
    if (userId) {
      formData.append('userId', userId);
    }
    return this.http.post<UploadResponse>(`${this.imageIngestionBaseUrl}/upload`, formData);
  }

  getMatchingRequest(id: string): Observable<MatchingRequest> {
    return this.http.get<MatchingRequest>(`${this.userCatalogBaseUrl}/catalog/matching-requests/${id}`);
  }
}
