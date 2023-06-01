resource "google_dns_managed_zone" "managed_zone" {
  name        = "my-dns-zone"
  dns_name    = "example.com."
  description = "My DNS Zone"
}

resource "google_dns_record_set" "record_set" {
  name         = "www.example.com."
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.managed_zone.name
  rrdatas      = ["1.2.3.4"]
}
