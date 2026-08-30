import { Component } from '@angular/core';
import { RouterOutlet, RouterLink } from '@angular/router';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet, RouterLink],
  template: `
    <nav class="container" style="display:flex; gap:16px; padding-top:16px;">
      <a routerLink="/login">Login</a>
      <a routerLink="/upload">Upload Coin</a>
      <a routerLink="/results">Matching Results</a>
    </nav>
    <router-outlet></router-outlet>
  `
})
export class AppComponent {}
