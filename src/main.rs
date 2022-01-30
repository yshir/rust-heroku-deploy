use std::net::SocketAddr;

use axum::{response::IntoResponse, routing, Json, Router};

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    init_logger();

    let app = Router::new().route("/", routing::get(ping));
    let addr = SocketAddr::from(([127, 0, 0, 1], 3000));

    tracing::info!("🚀 Server running on http://{}", addr);

    axum::Server::bind(&addr)
        .serve(app.into_make_service())
        .await
        .unwrap();

    Ok(())
}

async fn ping() -> impl IntoResponse {
    Json(serde_json::json!({ "ok": true }))
}

fn init_logger() {
    if std::env::var_os("RUST_LOG").is_none() {
        std::env::set_var("RUST_LOG", "rust_heroku_deploy=debug");
    }
    tracing_subscriber::fmt::init();
}
