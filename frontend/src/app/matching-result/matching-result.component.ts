import { Component, OnDestroy, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute } from '@angular/router';
import { Subscription, interval, switchMap, takeWhile } from 'rxjs';
import { ApiService, MatchingRequest } from '../core/services/api.service';

@Component({
  selector: 'app-matching-result',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="container">
      <div class="card">
        <h2>Matching Result</h2>

        <p *ngIf="!requestId">No matching request selected. Upload a coin photo first.</p>

        <ng-container *ngIf="result">
          <p [class]="'status-' + result.status.toLowerCase()">
            Status: <strong>{{ result.status }}</strong>
          </p>

          <div *ngIf="result.status === 'MATCHED'">
            <p>Matched coin ID: <strong>{{ result.matchedCoinId }}</strong></p>
            <p>Confidence: <strong>{{ (result.confidenceScore ?? 0) * 100 | number:'1.0-1' }}%</strong></p>
          </div>

          <div *ngIf="result.status === 'FAILED'">
            <p class="error">{{ result.errorMessage || 'No confident match was found.' }}</p>
          </div>

          <div *ngIf="result.status === 'PENDING' || result.status === 'PROCESSING'">
            <p>Analyzing your coin with AI… this usually takes a few seconds.</p>
          </div>
        </ng-container>
      </div>
    </div>
  `
})
export class MatchingResultComponent implements OnInit, OnDestroy {
  requestId: string | null = null;
  result: MatchingRequest | null = null;
  private pollSub?: Subscription;

  constructor(private route: ActivatedRoute, private api: ApiService) {}

  ngOnInit(): void {
    this.requestId = this.route.snapshot.queryParamMap.get('requestId');
    if (!this.requestId) {
      return;
    }

    // Poll every 2s until the request reaches a terminal state (MATCHED/FAILED)
    this.pollSub = interval(2000)
      .pipe(
        switchMap(() => this.api.getMatchingRequest(this.requestId as string)),
        takeWhile((res) => res.status === 'PENDING' || res.status === 'PROCESSING', true)
      )
      .subscribe((res) => (this.result = res));
  }

  ngOnDestroy(): void {
    this.pollSub?.unsubscribe();
  }
}
