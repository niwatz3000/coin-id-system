import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { ApiService } from '../core/services/api.service';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div class="container">
      <div class="card">
        <h2>Login</h2>

        <label>Email</label>
        <input type="email" [(ngModel)]="email" name="email" placeholder="you@example.com" />

        <label>Password</label>
        <input type="password" [(ngModel)]="password" name="password" />

        <button (click)="login()" [disabled]="loading">{{ loading ? 'Signing in…' : 'Login' }}</button>

        <p class="error" *ngIf="errorMessage">{{ errorMessage }}</p>
      </div>
    </div>
  `
})
export class LoginComponent {
  email = '';
  password = '';
  loading = false;
  errorMessage = '';

  constructor(private api: ApiService, private router: Router) {}

  login(): void {
    if (!this.email || !this.password) {
      this.errorMessage = 'Please enter email and password.';
      return;
    }
    this.loading = true;
    this.errorMessage = '';

    this.api.login(this.email, this.password).subscribe({
      next: (res) => {
        localStorage.setItem('coinid_token', res.token);
        this.loading = false;
        this.router.navigate(['/upload']);
      },
      error: () => {
        this.loading = false;
        this.errorMessage = 'Invalid email or password.';
      }
    });
  }
}
