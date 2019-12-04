# Import all plugins from `rel/plugins`
# They can then be used by adding `plugin MyPlugin` to
# either an environment, or release definition, where
# `MyPlugin` is the name of the plugin module.
~w(rel plugins *.exs)
|> Path.join()
|> Path.wildcard()
|> Enum.map(&Code.eval_file(&1))

use Distillery.Releases.Config,
  # This sets the default release built by `mix distillery.release`
  default_release: :default,
  # This sets the default environment used by `mix distillery.release`
  default_environment: Mix.env()

# For a full list of config options for both releases
# and environments, visit https://hexdocs.pm/distillery/config/distillery.html

# You may define one or more environments in this file,
# an environment's settings will override those of a release
# when building in that environment, this combination of release
# and environment configuration is called a profile

environment :dev do
  set(dev_mode: true)
  set(include_erts: false)
  set(cookie: :"pdxHcLoAby4I:6S(P$1A)DM^4l@)eWo*^W^y[^7H>a2Mmzbj<iuVgqQIZD*h=AG;")
end

environment :prod do
  set(
    config_providers: [
      {MongoosePush.Config.ConfexProvider, ["${RELEASE_ROOT_DIR}/config/prod.exs"]}
    ]
  )

  set(include_erts: true)
  set(include_src: false)
  set(cookie: :"w9fd^wfS`YIf5ID:B;9b(;ZNf5m6btx0LR6l/~UJyh=P~5V5YHn^P]F[.:FOkM4k")
  set(vm_args: "rel/vm.args")
end

# You may define one or more releases in this file.
# If you have not set a default release, or selected one
# when running `mix distillery.release`, the first release in the file
# will be used by default

release :mongoose_push do
  set(version: current_version(:mongoose_push))

  set(
    applications: [
      mongoose_push: :permanent,
      goth: :load
    ]
  )
end
