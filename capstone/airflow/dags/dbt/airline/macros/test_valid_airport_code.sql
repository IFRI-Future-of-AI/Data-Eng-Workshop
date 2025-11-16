{% test valid_airport_code(model, column_name) %}
    {#
        Test personnalisé: valid_airport_code
        Description: Vérifie que les codes aéroport sont valides (3 caractères alphabétiques majuscules)
        
        Paramètres:
            - model: Modèle à tester
            - column_name: Colonne contenant le code aéroport
        
        Utilisation dans un fichier .yml:
            tests:
              - valid_airport_code:
                  column_name: airport_code
    #}
    
    SELECT
        {{ column_name }} AS invalid_airport_code,
        COUNT(*) AS invalid_count
    FROM {{ model }}
    WHERE 
        {{ column_name }} IS NOT NULL
        AND (
            length({{ column_name }}) != 3
            OR NOT match({{ column_name }}, '^[A-Z]{3}$')
        )
    GROUP BY {{ column_name }}
    HAVING COUNT(*) > 0

{% endtest %}
