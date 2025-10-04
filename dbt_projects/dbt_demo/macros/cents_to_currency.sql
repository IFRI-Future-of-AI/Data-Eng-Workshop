{% macro cents_to_currency(amount_col, decimals=2) %}
    {#
        Convertit un montant en centimes vers une devise (dollars, euros, etc.)
        
        Args:
            amount_col: Colonne contenant le montant en centimes
            decimals: Nombre de décimales (par défaut 2)
        
        Returns:
            Montant converti avec décimales
        
        Exemple:
            {{ cents_to_currency('total_amount') }}
            {{ cents_to_currency('total_amount', 0) }}
    #}
    
    ROUND({{ amount_col }} / 100.0, {{ decimals }})
{% endmacro %}
