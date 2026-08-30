import { Routes } from '@angular/router';
import { LoginComponent } from './login/login.component';
import { UploadComponent } from './upload/upload.component';
import { MatchingResultComponent } from './matching-result/matching-result.component';

export const routes: Routes = [
  { path: '', redirectTo: 'login', pathMatch: 'full' },
  { path: 'login', component: LoginComponent },
  { path: 'upload', component: UploadComponent },
  { path: 'results', component: MatchingResultComponent },
  { path: '**', redirectTo: 'login' }
];
