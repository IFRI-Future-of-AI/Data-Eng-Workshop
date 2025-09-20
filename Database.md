Voici un résumé du schéma de la base de données de démonstration « Airlines » :

- **Table principale : `bookings`**
  - Représente une réservation (booking).

- **Billets : `tickets`**
  - Chaque réservation peut inclure plusieurs passagers, chacun avec un billet distinct.
  - Un billet contient le nom et l'identité du passager (pas d'entité séparée pour le passager, on suppose que chaque passager est unique).

- **Segments de vol : `ticket_flights`**
  - Un billet peut contenir plusieurs segments de vol (correspondances, aller-retour).
  - Il est supposé que tous les billets d'une même réservation ont les mêmes segments.

- **Vols : `flights`**
  - Chaque vol va d’un aéroport (`airports`) à un autre.
  - Même numéro de vol signifie mêmes points de départ/destination, mais la date varie.

- **Cartes d’embarquement : `boarding_passes`**
  - Un passager reçoit une carte avec numéro de siège au check-in.
  - Un vol et un siège donnés ne peuvent être assignés qu’une fois par vol.

- **Sièges et classes : `seats` et `aircrafts`**
  - Les sièges dépendent du modèle d’appareil (`aircrafts`) utilisé pour le vol.
  - Chaque modèle a une configuration de cabine unique.

Ce schéma gère les associations de réservation, billets, segments de vol, check-ins, sièges et avions utilisés, dans un contexte proche d'une compagnie aérienne.