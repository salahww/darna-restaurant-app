// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Restaurant Darna';

  @override
  String get home => 'Accueil';

  @override
  String get menu => 'Menu';

  @override
  String get cart => 'Panier';

  @override
  String get profile => 'Profil';

  @override
  String get settings => 'Paramètres';

  @override
  String get language => 'Langue';

  @override
  String get theme => 'Thème';

  @override
  String get darkMode => 'Mode Sombre';

  @override
  String get lightMode => 'Mode Clair';

  @override
  String get systemMode => 'Système';

  @override
  String get favorites => 'Favoris';

  @override
  String get addToCart => 'Ajouter au panier';

  @override
  String get checkout => 'Commander';

  @override
  String get total => 'Total';

  @override
  String get myOrders => 'Mes Commandes';

  @override
  String get deliveryAddress => 'Adresse de livraison';

  @override
  String get paymentMethod => 'Méthode de paiement';

  @override
  String get placeOrder => 'Passer la commande';

  @override
  String get login => 'Connexion';

  @override
  String get logout => 'Déconnexion';

  @override
  String get search => 'Rechercher des plats...';

  @override
  String get welcome => 'Bienvenue chez Darna';

  @override
  String get fastDelivery => 'Livraison Rapide';

  @override
  String get freshFood => 'Nourriture Fraîche';

  @override
  String get guestUser => 'Utilisateur Invité';

  @override
  String get signedIn => 'Connecté';

  @override
  String get guestEmail => 'invite@darna.ma';

  @override
  String get viewAll => 'Voir Tout';

  @override
  String get loginToSeeOrders => 'Connectez-vous pour voir les commandes';

  @override
  String get noOrdersYet => 'Pas encore de commande';

  @override
  String get orderHistoryMsg => 'Votre historique apparaîtra ici';

  @override
  String get orderNum => 'Commande #';

  @override
  String get helpSupport => 'Aide & Support';

  @override
  String get exploreMenu => 'Explorer le Menu';

  @override
  String get noFavorites => 'Pas de favoris';

  @override
  String get saveFavoritesMsg => 'Sauvegardez vos plats préférés ici';

  @override
  String get clearAll => 'Tout Effacer';

  @override
  String get clearedFavorites => 'Tous les favoris effacés';

  @override
  String get picksForYou => 'Choisi pour vous';

  @override
  String get deliveringTo => 'Livraison à';

  @override
  String get searchPlaceholder => 'Rechercher des plats...';

  @override
  String get categories => 'Catégories';

  @override
  String get seeAll => 'Voir Tout';

  @override
  String get loadingDishDetails => 'Chargement des détails...';

  @override
  String get error => 'Erreur';

  @override
  String get failedToLoadProduct => 'Impossible de charger les détails';

  @override
  String get goBack => 'Retour';

  @override
  String get addedToFavorites => 'Ajouté aux favoris';

  @override
  String get removedFromFavorites => 'Retiré des favoris';

  @override
  String get reviews => 'avis';

  @override
  String get description => 'Description';

  @override
  String get ingredients => 'Ingrédients';

  @override
  String get nutritionalInfo => 'Informations Nutritionnelles';

  @override
  String get calories => 'Calories';

  @override
  String get protein => 'Protéines';

  @override
  String get carbs => 'Glucides';

  @override
  String get fats => 'Lipides';

  @override
  String get portionSize => 'Portion';

  @override
  String get spiceLevelOptional => 'Niveau d\'épices (Optionnel)';

  @override
  String get addOns => 'Suppléments';

  @override
  String get specialInstructions => 'Instructions Spéciales';

  @override
  String get specialInstructionsHint =>
      'Demandes spéciales ? (ex: sans oignons)';

  @override
  String addedProductToCart(String productName) {
    return '$productName ajouté au panier !';
  }

  @override
  String get viewCart => 'VOIR PANIER';

  @override
  String get catTagines => 'Tajines';

  @override
  String get catCouscous => 'Couscous';

  @override
  String get catPastilla => 'Pastilla';

  @override
  String get catStarters => 'Entrées';

  @override
  String get catGrills => 'Grillades';

  @override
  String get catDesserts => 'Desserts';

  @override
  String get catDrinks => 'Boissons';

  @override
  String get shoppingCart => 'Panier';

  @override
  String get clear => 'Effacer';

  @override
  String get clearCartConfirmTitle => 'Vider le panier ?';

  @override
  String get clearCartConfirmMsg =>
      'Êtes-vous sûr de vouloir supprimer tous les articles de votre panier ?';

  @override
  String get cancel => 'Annuler';

  @override
  String get yourCartIsEmpty => 'Votre panier est vide';

  @override
  String get addItemsToCartMsg => 'Ajoutez de délicieux plats pour commencer';

  @override
  String get browseMenu => 'Parcourir le menu';

  @override
  String get subtotal => 'Sous-total';

  @override
  String get deliveryFee => 'Frais de livraison';

  @override
  String get freeDelivery => 'GRATUIT';

  @override
  String freeDeliveryMsg(String amount) {
    return 'Ajoutez $amount DH de plus pour la livraison gratuite';
  }

  @override
  String get proceedToCheckout => 'Passer à la caisse';

  @override
  String get comingSoon => 'Bientôt disponible !';

  @override
  String get checkoutComingSoonMsg =>
      'Les fonctionnalités de paiement sont en cours de développement. Restez à l\'écoute !';

  @override
  String get gotIt => 'Compris';

  @override
  String get enterAddressHint => 'Entrez l\'adresse de rue, appartement...';

  @override
  String get phoneHint => 'Numéro de téléphone pour la livraison';

  @override
  String get cod => 'Paiement à la livraison';

  @override
  String get creditCard => 'Carte de crédit';

  @override
  String get totalAmount => 'Montant total';

  @override
  String get orderPlacedTitle => 'Commande passée ! 🎉';

  @override
  String get orderPlacedMsg =>
      'Votre commande a été reçue et est en cours de préparation.';

  @override
  String get ok => 'OK';

  @override
  String get aiChefTitle => 'Chef AI Darna';

  @override
  String get typing => 'Écrit...';

  @override
  String get online => 'En ligne';

  @override
  String get chefThinking => 'Le chef réfléchit...';

  @override
  String get askMenuHint => 'Demandez sur notre menu...';

  @override
  String get pleaseLoginOrders =>
      'Veuillez vous connecter pour voir les commandes';

  @override
  String moreItems(int count) {
    return '+ $count autres articles';
  }

  @override
  String orderId(String id) {
    return 'Commande #$id';
  }

  @override
  String get statusPending => 'En attente';

  @override
  String get statusConfirmed => 'Confirmé';

  @override
  String get statusPreparing => 'En préparation';

  @override
  String get statusOutForDelivery => 'En livraison';

  @override
  String get statusDelivered => 'Livré';

  @override
  String get statusCancelled => 'Annulé';

  @override
  String get enterAddressError => 'Veuillez entrer une adresse de livraison';

  @override
  String get orderSummary => 'Résumé de la commande';

  @override
  String get orderStatusTitle => 'Statut de la commande';

  @override
  String get orderPlaced => 'Commande passée';

  @override
  String get estimatedDelivery => 'Estimé';

  @override
  String get confirm => 'Confirm';
}
