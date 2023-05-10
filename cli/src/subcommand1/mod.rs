mod config;
mod error;

pub use self::{
    config::Config,
    error::{Error, Result},
};

pub async fn run(_config: Config) -> Result<()> {
    let _a = futures::future::ok::<i32, i32>(1).await.expect("the future always success");
    Ok(())
}
