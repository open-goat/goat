package project_test

import (
	"testing"

	"github.com/opengoats/goat/cmd/goat/project"
	"github.com/stretchr/testify/assert"
)

func TestSaveFile(t *testing.T) {
	should := assert.New(t)

	p := project.Project{
		PKG:  "test",
		Name: "test",
	}

	err := p.SaveFile(project.PROJECT_SETTING_FILE_PATH)
	should.NoError(err)
}

func TestInit(t *testing.T) {
	should := assert.New(t)

	p := project.Project{
		PKG:  "test",
		Name: "test",
	}

	err := p.Init()
	should.NoError(err)
}
