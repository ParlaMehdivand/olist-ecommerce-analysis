import pandas as pd
from pathlib import Path


# Path to the data folder
DATA_PATH = Path(__file__).parent.parent / "data"


def load_data():
    customers = pd.read_csv(DATA_PATH / "olist_customers_dataset.csv")
    orders = pd.read_csv(DATA_PATH / "olist_orders_dataset.csv")
    order_items = pd.read_csv(DATA_PATH / "olist_order_items_dataset.csv")
    order_payments = pd.read_csv(DATA_PATH / "olist_order_payments_dataset.csv")
    order_reviews = pd.read_csv(DATA_PATH / "olist_order_reviews_dataset.csv")
    products = pd.read_csv(DATA_PATH / "olist_products_dataset.csv")
    sellers = pd.read_csv(DATA_PATH / "olist_sellers_dataset.csv")
    geolocation = pd.read_csv(DATA_PATH / "olist_geolocation_dataset.csv")
    category_translation = pd.read_csv(DATA_PATH / "product_category_name_translation.csv")

    return {
        "customers": customers,
        "orders": orders,
        "order_items": order_items,
        "order_payments": order_payments,
        "order_reviews": order_reviews,
        "products": products,
        "sellers": sellers,
        "geolocation": geolocation,
        "category_translation": category_translation,
    }