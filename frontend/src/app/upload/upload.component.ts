import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';
import { ApiService } from '../core/services/api.service';

@Component({
  selector: 'app-upload',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="container">
      <div class="card">
        <h2>Upload a Coin Photo</h2>
        <p>Take a clear, well-lit photo of the coin (front side) and upload it for identification.</p>

        <input type="file" accept="image/png, image/jpeg, image/webp" (change)="onFileSelected($event)" />

        <div *ngIf="previewUrl" style="margin: 16px 0;">
          <img [src]="previewUrl" alt="Preview" style="max-width:100%; border-radius:8px;" />
        </div>

        <button (click)="upload()" [disabled]="!selectedFile || uploading">
          {{ uploading ? 'Uploading…' : 'Identify Coin' }}
        </button>

        <p class="error" *ngIf="errorMessage">{{ errorMessage }}</p>
      </div>
    </div>
  `
})
export class UploadComponent {
  selectedFile: File | null = null;
  previewUrl: string | null = null;
  uploading = false;
  errorMessage = '';

  constructor(private api: ApiService, private router: Router) {}

  onFileSelected(event: Event): void {
    const input = event.target as HTMLInputElement;
    if (input.files && input.files.length > 0) {
      this.selectedFile = input.files[0];
      this.previewUrl = URL.createObjectURL(this.selectedFile);
      this.errorMessage = '';
    }
  }

  upload(): void {
    if (!this.selectedFile) {
      return;
    }
    this.uploading = true;
    this.errorMessage = '';

    this.api.uploadCoinImage(this.selectedFile).subscribe({
      next: (res) => {
        this.uploading = false;
        this.router.navigate(['/results'], { queryParams: { requestId: res.matchingRequestId } });
      },
      error: () => {
        this.uploading = false;
        this.errorMessage = 'Upload failed. Please try again.';
      }
    });
  }
}
