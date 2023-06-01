resource "google_sql_database_instance" "sql_instance" {
  name             = "my-sql-instance"
  database_version = "POSTGRES_13"
  region           = "southamerica-east1"
  project          = "my-project-id"
  settings {
    tier = "db-f1-micro"
  }
}

resource "google_sql_user" "sql_user" {
  name     = "my-user"
  instance = google_sql_database_instance.sql_instance.name
  password = "8P1pi4ofXtzf5VKF"
}

resource "google_sql_database" "database" {
  name     = "my-database"
  instance = google_sql_database_instance.sql_instance.name
}

resource "google_sql_user_instance" "sql_user_instance" {
  name      = google_sql_user.sql_user.name
  host      = "%"
  instance  = google_sql_database_instance.sql_instance.name
  password  = google_sql_user.sql_user.password
}
