class AppStrings {
  final bool isArabic;

  AppStrings(this.isArabic);

  // App
  String get appName => isArabic ? 'شبكتي' : 'Shabakti';
  String get appTagline => isArabic ? 'باقات الإنترنت في يدك' : 'Internet packages in your hand';

  // Auth
  String get login => isArabic ? 'تسجيل الدخول' : 'Login';
  String get loginSubtitle => isArabic ? 'سجّل دخولك للمتابعة' : 'Sign in to continue';
  String get email => isArabic ? 'البريد الإلكتروني' : 'Email';
  String get password => isArabic ? 'كلمة السر' : 'Password';
  String get forgotPassword => isArabic ? 'نسيت كلمة السر؟' : 'Forgot password?';
  String get noAccount => isArabic ? 'ليس لديك حساب؟' : "Don't have an account?";
  String get createAccount => isArabic ? 'إنشاء حساب جديد' : 'Create new account';
  String get or => isArabic ? 'أو' : 'or';
  String get required => isArabic ? 'مطلوب' : 'Required';

  // Register
  String get personalInfo => isArabic ? 'البيانات الشخصية' : 'Personal Info';
  String get personalInfoSub => isArabic ? 'أدخل بياناتك لإنشاء حساب جديد' : 'Enter your info to create an account';
  String get fullName => isArabic ? 'الاسم الكامل' : 'Full Name';
  String get phone => isArabic ? 'رقم الهاتف' : 'Phone Number';
  String get sendOtp => isArabic ? 'إرسال كود التحقق' : 'Send verification code';
  String get haveAccount => isArabic ? 'لديك حساب بالفعل؟ تسجيل الدخول' : 'Already have an account? Login';
  String stepOf(int step) => isArabic ? 'الخطوة $step من 3' : 'Step $step of 3';

  // OTP
  String get otpTitle => isArabic ? 'كود التحقق' : 'Verification Code';
  String get otpSent => isArabic ? 'تم إرسال الكود على بريدك الإلكتروني' : 'Code sent to your email';
  String get confirmCode => isArabic ? 'تأكيد الكود' : 'Confirm Code';
  String get noCode => isArabic ? 'لم يصلك الكود؟ إعادة الإرسال' : "Didn't receive the code? Resend";

  // Set Password
  String get createPassword => isArabic ? 'إنشاء كلمة السر' : 'Create Password';
  String get createPasswordSub => isArabic ? 'اختر كلمة سر قوية لحماية حسابك' : 'Choose a strong password';
  String get confirmPassword => isArabic ? 'تأكيد كلمة السر' : 'Confirm Password';
  String get createAccountBtn => isArabic ? 'إنشاء الحساب' : 'Create Account';
  String get accountCreated => isArabic ? 'تم إنشاء الحساب بنجاح!' : 'Account created successfully!';
  String get strengthWeak => isArabic ? 'ضعيفة' : 'Weak';
  String get strengthMedium => isArabic ? 'متوسطة' : 'Medium';
  String get strengthStrong => isArabic ? 'قوية' : 'Strong';
  String strengthLabel(int level) => isArabic
      ? 'قوة كلمة السر: ${level <= 1 ? strengthWeak : level == 2 ? strengthMedium : strengthStrong}'
      : 'Password strength: ${level <= 1 ? strengthWeak : level == 2 ? strengthMedium : strengthStrong}';

  // Home
  String greeting(String name) => isArabic ? 'مرحباً، $name 👋' : 'Hello, $name 👋';
  String get noActiveSub => isArabic ? 'لا يوجد اشتراك نشط' : 'No active subscription';
  String get choosePlan => isArabic ? 'اختر باقتك' : 'Choose your plan';
  String get active => isArabic ? 'نشط' : 'Active';
  String get gbRemaining => isArabic ? 'GB متبقي' : 'GB remaining';
  String get connectionInfo => isArabic ? 'بيانات الاتصال' : 'Connection Info';
  String get username => isArabic ? 'المستخدم' : 'Username';
  String get copied => isArabic ? 'تم النسخ' : 'Copied';

  // Packages
  String get daily => isArabic ? 'يومية' : 'Daily';
  String get weekly => isArabic ? 'أسبوعية' : 'Weekly';
  String get monthly => isArabic ? 'شهرية' : 'Monthly';
  String get additional => isArabic ? 'إضافية' : 'Add-on';
  String get egp => isArabic ? 'ج.م' : 'EGP';
  String get subscribeNow => isArabic ? 'اشترك الآن' : 'Subscribe Now';
  String get packageDetails => isArabic ? 'تفاصيل الباقة' : 'Package Details';

  // Usage
  String get usageTitle => isArabic ? 'استهلاك الإنترنت' : 'Data Usage';
  String get total => isArabic ? 'الإجمالي' : 'Total';
  String get used => isArabic ? 'المستهلك' : 'Used';
  String get remaining => isArabic ? 'المتبقي' : 'Remaining';
  String daysLeft(int d) => isArabic ? '$d يوم متبقية' : '$d days left';
  String get usageDetails => isArabic ? 'تفاصيل الاستهلاك' : 'Usage Details';
  String get subscriptionHistory => isArabic ? 'سجل الاشتراكات' : 'Subscription History';
  String get viewAll => isArabic ? 'عرض الكل' : 'View All';

  // Profile
  String get myAccount => isArabic ? 'حسابي' : 'My Account';
  String get editProfile => isArabic ? 'تعديل البيانات الشخصية' : 'Edit Profile';
  String get changePassword => isArabic ? 'تغيير كلمة السر' : 'Change Password';
  String get beneficiaries => isArabic ? 'المستفيدون' : 'Beneficiaries';
  String get deleteAccount => isArabic ? 'حذف الحساب' : 'Delete Account';
  String get logout => isArabic ? 'تسجيل الخروج' : 'Logout';
  String get user => isArabic ? 'مستخدم' : 'User';
  String get beneficiary => isArabic ? 'مستفيد' : 'Beneficiary';

  // Payment
  String get payment => isArabic ? 'إتمام الدفع' : 'Complete Payment';
  String get chooseMethod => isArabic ? 'اختر طريقة الدفع' : 'Choose payment method';
  String get uploadProof => isArabic ? 'رفع إثبات الدفع' : 'Upload payment proof';
  String get confirmPayment => isArabic ? 'تأكيد الدفع' : 'Confirm Payment';
  String get paymentSuccess => isArabic ? 'تم تفعيل الباقة بنجاح!' : 'Package activated successfully!';
  String get goHome => isArabic ? 'الذهاب للرئيسية' : 'Go to Home';

  // Nav
  String get navHome => isArabic ? 'الرئيسية' : 'Home';
  String get navUsage => isArabic ? 'الاستهلاك' : 'Usage';
  String get navProfile => isArabic ? 'حسابي' : 'Profile';
}
