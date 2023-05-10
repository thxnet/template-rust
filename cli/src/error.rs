use snafu::Snafu;

pub type Result<T> = std::result::Result<T, Error>;

#[derive(Debug, Snafu)]
#[snafu(visibility(pub))]
pub enum Error {
    #[snafu(display("Could not initialize tokio runtime, error: {source}"))]
    InitializeTokioRuntime { source: tokio::io::Error },

    #[snafu(display("{source}"))]
    Subcommand1 { source: crate::subcommand1::Error },

    #[snafu(display("{source}"))]
    Subcommand2 { source: crate::subcommand2::Error },

    #[snafu(display("{source}"))]
    Subcommand3 { source: crate::subcommand3::Error },
}

impl From<crate::subcommand1::Error> for Error {
    fn from(source: crate::subcommand1::Error) -> Self { Self::Subcommand1 { source } }
}

impl From<crate::subcommand2::Error> for Error {
    fn from(source: crate::subcommand2::Error) -> Self { Self::Subcommand2 { source } }
}

impl From<crate::subcommand3::Error> for Error {
    fn from(source: crate::subcommand3::Error) -> Self { Self::Subcommand3 { source } }
}

pub trait CommandError {
    fn exit_code(&self) -> exitcode::ExitCode;
}

impl CommandError for Error {
    fn exit_code(&self) -> exitcode::ExitCode {
        match self {
            Self::InitializeTokioRuntime { .. } => exitcode::IOERR,
            Self::Subcommand1 { source } => source.exit_code(),
            Self::Subcommand2 { source } => source.exit_code(),
            Self::Subcommand3 { source } => source.exit_code(),
        }
    }
}
