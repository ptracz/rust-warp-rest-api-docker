use warp::{Filter, Rejection, Reply};
use log::{debug, info};

type Result<T> = std::result::Result<T, Rejection>;

#[tokio::main]
async fn main() {

    env_logger::init();

    let health_route = warp::path!("health").and_then(health_handler);

    let routes = health_route.with(warp::cors().allow_any_origin());

    debug!("Started server at localhost:8000");
    warp::serve(routes).run(([0, 0, 0, 0], 8000)).await;
}

async fn health_handler() -> Result<impl Reply> {
    info!("health check was called");
    Ok("1")
}
