import 'package:flutter/material.dart';

class AppStrings {
  static const Map<String, Map<String, String>> _localizedValues = {
    'ar': {
      // App
      'appName': 'GoDarna',
      'appSlogan': 'منصة تأجير العقارات المغربية',
      
      // Auth
      'login': 'تسجيل الدخول',
      'register': 'إنشاء حساب',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'confirmPassword': 'تأكيد كلمة المرور',
      'forgotPassword': 'نسيت كلمة المرور؟',
      'sendOtp': 'إرسال رمز التحقق',
      'verifyOtp': 'تحقق من الرمز',
      'otpSent': 'تم إرسال رمز التحقق',
      'otpInvalid': 'رمز التحقق غير صحيح',
      'loginSuccess': 'تم تسجيل الدخول بنجاح',
      'logout': 'تسجيل الخروج',
      'loginRequired': 'تسجيل الدخول مطلوب',
      
      // Navigation
      'home': 'الرئيسية',
      'search': 'البحث',
      'navBookings': 'الحجوزات',
      'navProfile': 'الملف الشخصي',
      'addProperty': 'إضافة عقار',
      'myProperties': 'عقاراتي',
      
      // Property
      'property': 'عقار',
      'properties': 'عقارات',
      'propertyType': 'نوع العقار',
      'apartment': 'شقة',
      'villa': 'فيلا',
      'riad': 'رياض',
      'studio': 'استوديو',
      'price': 'السعر',
      'pricePerNight': 'السعر لليلة الواحدة',
      'pricePerMonth': 'السعر للشهر',
      'location': 'الموقع',
      'address': 'العنوان',
      'city': 'المدينة',
      'area': 'المنطقة',
      'rooms': 'الغرف',
      'bedrooms': 'غرف النوم',
      'bathrooms': 'الحمامات',
      'guests': 'عدد الضيوف',
      'description': 'الوصف',
      'amenities': 'المرافق',
      'photos': 'الصور',
      'addPhoto': 'إضافة صورة',
      'removePhoto': 'حذف الصورة',
      'noPropertiesFound': 'لا توجد عقارات',
      'noSearchResults': 'لا توجد نتائج بحث',
      'noPropertiesYet': 'لا توجد عقارات بعد',
      'addFirstProperty': 'أضف أول عقار',
      
      // Search & Filters
      'searchProperties': 'البحث عن عقارات',
      'filters': 'الفلاتر',
      'priceRangeFilter': 'نطاق السعر',
      'propertyTypeFilter': 'نوع العقار',
      'locationFilter': 'الموقع',
      'dateRangeFilter': 'نطاق التاريخ',
      'guestsFilter': 'عدد الضيوف',
      'applyFilters': 'تطبيق الفلاتر',
      'clearFilters': 'مسح الفلاتر',
      
      // Booking
      'book': 'حجز',
      'booking': 'حجز',
      'bookingList': 'الحجوزات',
      'myBookings': 'حجوزاتي',
      'checkIn': 'تاريخ الوصول',
      'checkOut': 'تاريخ المغادرة',
      'nights': 'الليالي',
      'totalPrice': 'السعر الإجمالي',
      'bookingConfirmed': 'تم تأكيد الحجز',
      'bookingPending': 'في انتظار التأكيد',
      'bookingCancelled': 'تم إلغاء الحجز',
      'cancelBooking': 'إلغاء الحجز',
      'confirmBooking': 'تأكيد الحجز',
      'upcoming': 'قادمة',
      'active': 'نشطة',
      'completed': 'مكتملة',
      
      // Payment
      'payment': 'الدفع',
      'paymentMethod': 'طريقة الدفع',
      'cashOnDelivery': 'الدفع نقداً عند الوصول',
      'onlinePayment': 'الدفع الإلكتروني',
      'paymentSuccess': 'تم الدفع بنجاح',
      'paymentFailed': 'فشل في الدفع',
      
      // Profile
      'profile': 'الملف الشخصي',
      'editProfile': 'تعديل الملف',
      'personalInfo': 'المعلومات الشخصية',
      'firstName': 'الاسم الأول',
      'lastName': 'اسم العائلة',
      'phone': 'رقم الهاتف',
      'language': 'اللغة',
      'arabic': 'العربية',
      'french': 'الفرنسية',
      'settings': 'الإعدادات',
      'notifications': 'الإشعارات',
      'privacy': 'الخصوصية',
      'help': 'المساعدة',
      'about': 'حول التطبيق',
      
      // Common
      'save': 'حفظ',
      'cancel': 'إلغاء',
      'delete': 'حذف',
      'edit': 'تعديل',
      'add': 'إضافة',
      'remove': 'إزالة',
      'confirm': 'تأكيد',
      'back': 'رجوع',
      'next': 'التالي',
      'previous': 'السابق',
      'loading': 'جاري التحميل...',
      'error': 'خطأ',
      'success': 'نجح',
      'warning': 'تحذير',
      'info': 'معلومات',
      'noData': 'لا توجد بيانات',
      'retry': 'إعادة المحاولة',
      'close': 'إغلاق',
      'yes': 'نعم',
      'no': 'لا',
      'ok': 'حسناً',
      
      // Validation
      'required': 'مطلوب',
      'invalidEmail': 'بريد إلكتروني غير صحيح',
      'invalidPhone': 'رقم هاتف غير صحيح',
      'passwordTooShort': 'كلمة المرور قصيرة جداً',
      'passwordsDoNotMatch': 'كلمات المرور غير متطابقة',
      
      // Notifications
      'newBooking': 'حجز جديد',
      'newMessage': 'رسالة جديدة',
      'welcomeMessage': 'مرحباً بك في GoDarna',
    },
    'fr': {
      // App
      'appName': 'GoDarna',
      'appSlogan': 'Plateforme de location immobilière marocaine',
      
      // Auth
      'login': 'Connexion',
      'register': 'Créer un compte',
      'email': 'E-mail',
      'password': 'Mot de passe',
      'confirmPassword': 'Confirmer le mot de passe',
      'forgotPassword': 'Mot de passe oublié ?',
      'sendOtp': 'Envoyer le code de vérification',
      'verifyOtp': 'Vérifier le code',
      'otpSent': 'Code de vérification envoyé',
      'otpInvalid': 'Code de vérification incorrect',
      'loginSuccess': 'Connexion réussie',
      'logout': 'Déconnexion',
      'loginRequired': 'Connexion requise',
      
      // Navigation
      'home': 'Accueil',
      'search': 'Recherche',
      'navBookings': 'Réservations',
      'navProfile': 'Profil',
      'addProperty': 'Ajouter une propriété',
      'myProperties': 'Mes propriétés',
      
      // Property
      'property': 'Propriété',
      'properties': 'Propriétés',
      'propertyType': 'Type de propriété',
      'apartment': 'Appartement',
      'villa': 'Villa',
      'riad': 'Riad',
      'studio': 'Studio',
      'price': 'Prix',
      'pricePerNight': 'Prix par nuit',
      'pricePerMonth': 'Prix par mois',
      'location': 'Emplacement',
      'address': 'Adresse',
      'city': 'Ville',
      'area': 'Zone',
      'rooms': 'Pièces',
      'bedrooms': 'Chambres',
      'bathrooms': 'Salles de bain',
      'guests': 'Voyageurs',
      'description': 'Description',
      'amenities': 'Équipements',
      'photos': 'Photos',
      'addPhoto': 'Ajouter une photo',
      'removePhoto': 'Supprimer la photo',
      'noPropertiesFound': 'Aucune propriété trouvée',
      'noSearchResults': 'Aucun résultat de recherche',
      'noPropertiesYet': 'Aucune propriété encore',
      'addFirstProperty': 'Ajouter la première propriété',
      
      // Search & Filters
      'searchProperties': 'Rechercher des propriétés',
      'filters': 'Filtres',
      'priceRange': 'Fourchette de prix',
      'propertyTypeFilter': 'Type de propriété',
      'locationFilter': 'Emplacement',
      'dateRange': 'Plage de dates',
      'guestsFilter': 'Nombre de voyageurs',
      'applyFilters': 'Appliquer les filtres',
      'clearFilters': 'Effacer les filtres',
      
      // Booking
      'book': 'Réserver',
      'booking': 'Réservation',
      'bookings': 'Réservations',
      'myBookings': 'Mes réservations',
      'checkIn': 'Date d\'arrivée',
      'checkOut': 'Date de départ',
      'nights': 'Nuits',
      'totalPrice': 'Prix total',
      'bookingConfirmed': 'Réservation confirmée',
      'bookingPending': 'En attente de confirmation',
      'bookingCancelled': 'Réservation annulée',
      'cancelBooking': 'Annuler la réservation',
      'confirmBooking': 'Confirmer la réservation',
      'upcoming': 'À venir',
      'active': 'Actives',
      'completed': 'Terminées',
      
      // Payment
      'payment': 'Paiement',
      'paymentMethod': 'Méthode de paiement',
      'cashOnDelivery': 'Paiement en espèces à l\'arrivée',
      'onlinePayment': 'Paiement en ligne',
      'paymentSuccess': 'Paiement réussi',
      'paymentFailed': 'Échec du paiement',
      
      // Profile
      'profile': 'Profil',
      'editProfile': 'Modifier le profil',
      'personalInfo': 'Informations personnelles',
      'firstName': 'Prénom',
      'lastName': 'Nom de famille',
      'phone': 'Numéro de téléphone',
      'language': 'Langue',
      'arabic': 'Arabe',
      'french': 'Français',
      'settings': 'Paramètres',
      'notifications': 'Notifications',
      'privacy': 'Confidentialité',
      'help': 'Aide',
      'about': 'À propos',
      
      // Common
      'save': 'Enregistrer',
      'cancel': 'Annuler',
      'delete': 'Supprimer',
      'edit': 'Modifier',
      'add': 'Ajouter',
      'remove': 'Retirer',
      'confirm': 'Confirmer',
      'back': 'Retour',
      'next': 'Suivant',
      'previous': 'Précédent',
      'loading': 'Chargement...',
      'error': 'Erreur',
      'success': 'Succès',
      'warning': 'Avertissement',
      'info': 'Information',
      'noData': 'Aucune donnée',
      'retry': 'Réessayer',
      'close': 'Fermer',
      'yes': 'Oui',
      'no': 'Non',
      'ok': 'OK',
      
      // Validation
      'required': 'Requis',
      'invalidEmail': 'E-mail invalide',
      'invalidPhone': 'Numéro de téléphone invalide',
      'passwordTooShort': 'Mot de passe trop court',
      'passwordsDoNotMatch': 'Les mots de passe ne correspondent pas',
      
      // Notifications
      'newBooking': 'Nouvelle réservation',
      'newMessage': 'Nouveau message',
      'welcomeMessage': 'Bienvenue sur GoDarna',
    },
  };

  static String getString(String key, BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final language = locale == 'ar' ? 'ar' : 'fr';
    
    return _localizedValues[language]?[key] ?? key;
  }

  static String getStringByLocale(String key, String languageCode) {
    final language = languageCode == 'ar' ? 'ar' : 'fr';
    return _localizedValues[language]?[key] ?? key;
  }
}