use crate::handler;
// use actix_web::web::Data;
use actix_web::{App, HttpServer};
// use std::sync::{Arc, Mutex};
use std::time::Duration;

pub struct ProvingServer {
    port: u16,
}

impl ProvingServer {
    pub fn new(port: u16) -> Self {
        ProvingServer { port }
    }
    pub async fn start_server(self) -> anyhow::Result<()> {
        HttpServer::new(move || App::new().configure(handler::routes))
            .client_request_timeout(Duration::new(0, 0))
            .bind(("localhost", self.port))
            .unwrap_or_else(|e| panic!("Can not bind to {}. Error: {}", &self.port, e))
            .run()
            .await
            .unwrap();

        Ok(())
    }
}
