from src.logger import configure_logging
import requests
import polars as pl 
from src.constants import NYC_TRIPS_URL, DATSET_FOLDER, TAXI_ZONE_URL
import os

logger = configure_logging(log_file="download.log", logger_name="download")

def verify_if_file_already_downloaded(file_path: str) -> bool:
    """
        Verify if file already downloaded
        Args:
            file_path (str): File path
        Returns:
            bool: True if file already downloaded, False otherwise
    """
    return os.path.exists(file_path)

def format_url(year: str, month: str) -> str:
    """
        Format URL
        Args:
            year (str): Year
            month (str): Month
        Returns:
            str: Formatted URL
    """
    return NYC_TRIPS_URL.format(year, month)

def download_data(url: str, file_path: str) -> None:
    """
        Download data from URL
        Args:
            url (str): URL
            file_path (str): File path
        Returns:
            None
    """
    logger.info(f"Downloading data from {url} to {file_path}")
    response = requests.get(url)
    # Check if request was successful
    if response.status_code == 200:
        logger.info(f"Data downloaded from {url} with status code {response.status_code}")
    elif response.status_code == 403 : 
        logger.error(f"File {url} not found, status code {response.status_code}")
        raise Exception(f"File {url} not found, status code {response.status_code}")
    else:
        logger.error(f"Failed to download data from {url} with status code {response.status_code}")
        raise Exception(f"Failed to download data from {url} with status code {response.status_code}")
    os.makedirs(os.path.dirname(file_path), exist_ok=True)
    with open(file_path, "wb") as f:
        f.write(response.content)
    logger.info(f"Data downloaded from {url} to {file_path}")
    return file_path

def download_data_for_month(year: str, month: str, download_dir: str = f"./data/{DATSET_FOLDER}") -> str:
    """
        Download data for month
        Args:
            year (str): Year
            month (str): Month
            download_dir (str): Download directory
        Returns:
            str: File path
    """
    url = format_url(year, month)
    file_path = os.path.join(download_dir, f"{year}-{month}.parquet")
    if verify_if_file_already_downloaded(file_path):
        logger.info(f"File {file_path} already downloaded, skipping download")
        return file_path
    return download_data(url, file_path)


def generate_month_range(start_month : str = '2009-01', 
                         end_month : str = '2025-12'
                        ) -> list:
    """
        Generate month range
        Args:
            start_month (str): Start month
            end_month (str): End month
        Returns:
            list: Month range
    """
    start_year, start_month = int(start_month[:4]), int(start_month[5:])
    end_year, end_month = int(end_month[:4]), int(end_month[5:])  # Correction ici: end_month[5:] au lieu de end_month[4:]
    month_range = []
    for year in range(start_year, end_year + 1):
        for month in range(start_month if year == start_year else 1, end_month + 1 if year == end_year else 13):
            month_range.append(f"{year}-{month:02d}")
    return month_range

def download_data_month_to_month(
                                start_month : str = '2009-01', 
                                end_month : str = '2025-12', 
                                download_dir: str = f"./data/{DATSET_FOLDER}"
) -> None:
    """
        Download data month to month
        Args:
            start_month (str): Start month
            end_month (str): End month
            download_dir (str): Download directory
        Returns:
            None
    """
    logger.info(f"Downloading data from {start_month} to {end_month} to {download_dir}")
    month_range = generate_month_range(start_month, end_month)
    for month in month_range:
        year, month_num = month.split('-')
        try:
            download_data_for_month(year, month_num, download_dir)
            logger.info(f"Successfully downloaded data for {year}-{month_num} to {download_dir}")
        except Exception as e:
            logger.error(f"Failed to download data for {year}-{month_num}, error: {e}")
    logger.info(f"Downloaded data from {start_month} to {end_month} to {download_dir}")
    
def download_taxi_zones() -> None:
    """
    Télécharge le fichier des zones de taxi, le convertit en parquet et supprime le CSV.
    """
    url = TAXI_ZONE_URL
    csv_path = "./data/yellow_tripdata/taxi_zones.csv"
    parquet_path = "./data/yellow_tripdata/taxi_zones.parquet"
    
    # Création du dossier si nécessaire
    os.makedirs("./data/yellow_tripdata", exist_ok=True)
    
    # Téléchargement du fichier
    logger.info(f"Téléchargement des zones de taxi depuis {url}")
    response = requests.get(url)
    
    if response.status_code != 200:
        logger.error(f"Échec du téléchargement des zones de taxi. Code: {response.status_code}")
        return
        
    # Sauvegarde du CSV
    with open(csv_path, "wb") as f:
        f.write(response.content)
    logger.info(f"Fichier CSV sauvegardé: {csv_path}")
    
    # Conversion en parquet
    try:
        df = pl.read_csv(csv_path)
        df.write_parquet(parquet_path)
        logger.info(f"Fichier converti en parquet: {parquet_path}")
        
        # Suppression du CSV
        os.remove(csv_path)
        logger.info("Fichier CSV supprimé")
    except Exception as e:
        logger.error(f"Erreur lors de la conversion: {str(e)}")