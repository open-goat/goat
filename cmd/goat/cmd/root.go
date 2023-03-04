package cmd

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"

	"github.com/open-goat/goat/cmd/goat/cmd/generate"
	"github.com/open-goat/goat/cmd/goat/cmd/project"
	"github.com/open-goat/goat/cmd/goat/cmd/protobuf"
)

var vers bool

// RootCmd represents the base command when called without any subcommands
var RootCmd = &cobra.Command{
	Use:   "goat",
	Short: "goat 分布式服务构建工具",
	Long:  `goat 分布式服务构建工具`,
	RunE: func(cmd *cobra.Command, args []string) error {
		return cmd.Help()
	},
}

// Execute adds all child commands to the root command sets flags appropriately.
// This is called by main.main(). It only needs to happen once to the rootCmd.
func Execute() {
	if err := RootCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(-1)
	}
}

func init() {
	RootCmd.AddCommand(project.Cmd, generate.Cmd, protobuf.Cmd)
	RootCmd.PersistentFlags().BoolVarP(&vers, "version", "v", false, "the goat version")
}
