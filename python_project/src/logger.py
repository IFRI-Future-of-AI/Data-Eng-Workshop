import os
import logging


def configure_logging(
    log_file: str,
    log_dir: str = "./logs",
    log_level: int = logging.INFO,
    logger_name: str = __name__,
) -> logging.Logger:
    """
        Configure logging
        Args:
            log_dir (str): Log directory path
            log_file (str): Log file name
            log_level (int): Log level
        Returns:
            logging.Logger: Logger object
    """
    # Create log directory if it doesn't exist
    os.makedirs(log_dir, exist_ok=True)
    # Create log file path  
    log_file = os.path.join(log_dir, log_file)

    logging.basicConfig(
        level=log_level,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        handlers=[
            logging.FileHandler(log_file, mode='a'),
            logging.StreamHandler()
        ]
    )
    logger = logging.getLogger(logger_name)
    
    return logger