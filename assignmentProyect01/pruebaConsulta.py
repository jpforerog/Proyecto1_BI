import pandas as pd
import os
import json

# 1. Definir la ruta de la carpeta que contiene los archivos CSV
carpeta_csv = r"C:\Users\jupaf\Documents\Proyecto1_BI\assignmentProyect01\assignmentProyect01\dataset"  # Ruta raw

# 2. Listar todos los archivos CSV en la carpeta
archivos_csv = [archivo for archivo in os.listdir(carpeta_csv) if archivo.endswith(".csv")]

# 3. Cargar los archivos CSV en DataFrames
dataframes = {}
for archivo in archivos_csv:
    nombre_archivo = os.path.splitext(archivo)[0]  # Obtener el nombre del archivo sin extensión
    ruta_completa = os.path.join(carpeta_csv, archivo)
    dataframes[nombre_archivo] = pd.read_csv(ruta_completa)

# 4. Acceder a los DataFrames cargados
olist_orders = dataframes.get("olist_orders_dataset")
olist_order_payments = dataframes.get("olist_order_payments_dataset")

# Verificar que los DataFrames se cargaron correctamente
print("Columnas en olist_orders:", olist_orders.columns)
print("Columnas en olist_order_payments:", olist_order_payments.columns)

# 5. Realizar la consulta
if olist_orders is not None and olist_order_payments is not None:
    # Convertir la columna de fecha a tipo datetime
    olist_orders["order_purchase_timestamp"] = pd.to_datetime(olist_orders["order_purchase_timestamp"])

    # Filtrar órdenes entregadas
    filtered_orders = olist_orders[
        (olist_orders["order_status"] == 'delivered') &
        (olist_orders["order_purchase_timestamp"].notna())  # Fecha de compra no nula
    ]

    # Unir las tablas
    merged_data = filtered_orders.merge(olist_order_payments, on="order_id")

    # Extraer mes y año
    merged_data["month_no"] = merged_data["order_purchase_timestamp"].dt.strftime('%m')  # Mes (01 a 12)
    merged_data["year"] = merged_data["order_purchase_timestamp"].dt.strftime('%Y')      # Año (2016, 2017, 2018)

    # Calcular el revenue por mes y año
    revenue_data = merged_data.groupby(["month_no", "year"]).agg(
        revenue=("payment_value", "sum")
    ).reset_index()

    # Crear una tabla con todos los meses (01 a 12)
    months = pd.DataFrame({
        "month_no": ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"],
        "month": ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    })

    # Pivotar los datos para tener una columna por año
    revenue_pivot = revenue_data.pivot(index="month_no", columns="year", values="revenue").fillna(0.00)

    # Unir los meses con los datos de ingresos
    result = months.merge(revenue_pivot, on="month_no", how="left").fillna(0.00)

    # Renombrar las columnas de años
    result = result.rename(columns={
        "2016": "Year2016",
        "2017": "Year2017",
        "2018": "Year2018"
    })

    # Redondear los valores a 2 decimales
    result["Year2016"] = result["Year2016"]
    result["Year2017"] = result["Year2017"]
    result["Year2018"] = result["Year2018"]

    # Ordenar por número de mes
    result = result.sort_values(by="month_no")

    # Guardar la tabla en un archivo JSON
    result.to_json("revenue_by_month_year.json", orient="records", indent=4)

    # Mostrar los resultados
    print(result)
else:
    print("No se pudieron cargar todos los DataFrames necesarios.")