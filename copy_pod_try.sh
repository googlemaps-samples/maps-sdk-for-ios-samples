#!/bin/sh
# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

POD_NAME="$1"
DESTINATION_DIR="$2"
POD_TRY_OPTION="$3"

echo "Invoking 'pod try $POD_NAME'"
POD_TRY_DIR="$(pod _1.6.1_ try $POD_NAME <<< $POD_TRY_OPTION | tail -1 | awk '{print $2}' | echo "/$(cut -d\/ -f2-11)")"

echo "Copying contents of '$POD_TRY_DIR' into '$DESTINATION_DIR'"
cp -R $POD_TRY_DIR/* $DESTINATION_DIR/.

