export type FlameBuildConfig = {
    --NetworkRoot: Folder?,
    EnableServerClientComms: boolean?,
}

export type ServerBuildProps = {
    ContextCommunicator: RemoteEvent?,
    DispatcherReceiver: RemoteFunction,
}
export type ClientBuildProps = {
    ContextCommunicator: RemoteEvent?,
    DispatcherReceiver: RemoteFunction,
}

export type Builder<P> = {
    __call: () -> Builder<P>,
    IS_BUILDING: boolean?,
    HAS_BUILT: boolean?,
    Props: P
}

return {}