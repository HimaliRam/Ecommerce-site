import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../services/auth.service';
import { HttpClient } from '@angular/common/http';
import { ChangeDetectorRef } from '@angular/core';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.css']
})
export class LoginComponent {

  email: string = '';
  password: string = '';
  showForgotModal = false;
  step = 1;

  resetEmail = '';
  otp = '';
  newPassword = '';

  constructor(private authService: AuthService, private http: HttpClient, private cdr: ChangeDetectorRef, private router: Router) { }

  login() {
    this.authService.login({
      email: this.email,
      password: this.password
    }).subscribe({

      next: (res: any) => {

        const userData = {
          id: res.id || res.userId || 1,   // ✅ ensure id exists
          name: res.name || res.email || 'User',
          email: res.email
        };

        localStorage.setItem('user', JSON.stringify(userData));
        this.cdr.detectChanges();

        alert('Login successful!');
        this.router.navigate(['/home']);
      },

      error: () => {
        alert('Invalid email or password');
      }
    });
  }
  goToRegister(event: Event) {
    event.preventDefault();
    this.router.navigate(['/register']);
  }
  openForgot() {
    console.log("Clicked Forgot Password"); // ✅ debug
    this.showForgotModal = true;
    this.cdr.detectChanges(); 
  }

  closeModal() {
    this.showForgotModal = false;
    this.step = 1;
  }
  sendOtp() {
    this.http.post('http://localhost:5112/api/auth/forgot-password', {
      email: this.resetEmail
    }).subscribe({
      next: (res: any) => {
        alert("Your OTP is: " + res.otp); // ✅ SHOW OTP
        this.step = 2;
        this.cdr.detectChanges(); 
      },
      error: (err) => {
        alert(err.error?.message || "Error sending OTP");
      }
    });
  }
  verifyOtp() {
    this.http.post('http://localhost:5112/api/auth/verify-otp', {
      email: this.resetEmail,
      otp: this.otp
    }).subscribe({
      next: (res: any) => {
        alert(res.message);
        this.step = 3;
        this.cdr.detectChanges();
      },
      error: (err) => {
        alert(err.error?.message || "Invalid OTP");
      }
    });
  }
  resetPassword() {
    this.http.post('http://localhost:5112/api/auth/reset-password', {
      email: this.resetEmail,
      password: this.newPassword
    }).subscribe((res: any) => {
      alert(res.message);
      this.closeModal();
      this.cdr.detectChanges();
    });
  }
}
